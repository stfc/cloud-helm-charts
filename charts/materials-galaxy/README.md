# Galaxy

Galaxy is a web-based platform for data analytics. 
See [Galaxy Docs](https://docs.galaxyproject.org/en/master/) 

This Chart deploys Galaxy configured to host materials-galaxy tools and allows authentication via IRIS-IAM

This chart deploys the [Galaxy Chart](https://github.com/galaxyproject/galaxy-helm) and the [Oauth2-Proxy Chart](https://github.com/oauth2-proxy/manifests/tree/main/helm/oauth2-proxy

# Prerequisites

## Storage
We've tested Galaxy using `longhorn` as default storage - for quick install, ensure longhorn is deployed and available to use

Other storage classes "should" work - as long as they support multiple containers accesssing the same volume (RWX)

## Ingress
For Galaxy to be accessible outside the cluster - we recommend using nginx ingress. Make sure its enabled on your cluster.


# Installation

## Populate Secrets

You'll need to configure the following secrets:
1. IRIS-IAM credentials and Galaxy admin credentials. 
2. Set a consistent password for galaxy user to access the postgreSQL database
   
See `secret-values.yaml.template` for how to set these values 
Copy the template file to a temporary directory outside of the repo - like `/tmp` and edit it

```bash
git clone https://github.com/stfc/cloud-helm-charts.git
cd cloud-helm-charts/charts/materials-galaxy
cp secret-values.yaml.template /tmp/secret-values.yaml
``` 

## Install Chart 

Then install the chart

```bash
helm repo add cloud-charts https://stfc.github.io/cloud-helm-charts/
helm repo update
helm install my-materials-galaxy cloud-charts/materials-galaxy -n materials-galaxy --create-namespace -f /tmp/secret-values.yaml
```


# Configuration

Galaxy is default set to deploy tools and config taken for "materials galaxy".

## Adding new tools

We use [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) to install galaxy tools from git.

To add a new set of galaxy tools - you can add a new init container definition under `extraInitContainers` like so:

We recommend creating a container image to install all your tools instead of using git image like below

```yaml
galaxy:
  ...
  extraInitContainers:
    ...
    - name: clone-my-tools # or name of your tools
      applyToJob: false
      applyToWeb: true # this should just apply to one pod - galaxy-web
      applyToWorkflow: false
      image: "alpine/git:latest" # or your setup image

      # this is an example of how to clone your tools using git
      command: ['sh', '-c', 'git clone https://github.com/me/my-tools.git --depth 1 --branch main {{.Values.persistence.mountPath}}/my-tools || true']
      volumeMounts:
        - name: galaxy-data
          mountPath: "{{.Values.persistence.mountPath}}"
```
`{{.Values.persistence.mountPath}}` is a reference to the filepath for the mounted shared volume - same on all containers

Then edit `galaxy.configs.tool_conf.xml` to make it available to users - add a xml entry like so:

 ```xml
 <tool file="{{.Values.persistence.mountPath}}/my-tools/my-tool-1/my-tool-1.xml>
``` 
where `file` is a filepath to the galaxy tool config you want to make available 

### Private repos

To deploy tools from a private repo - you need to create a git deploy key for that repo so that we can access it
more about deploy keys here - https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys#deploy-keys
Deploy keys are useful as they only grant access to a single repository, limiting attack vectors, additionally, we can set them to be read-only which is recommended for this use-case.

Once you create a deploy key, you need to add it to the secrets file under - be careful not to publish this as plaintext
```
gitRepos:
  - name: repo-name
    deployKey: |-
    -----BEGIN OPENSSH PRIVATE KEY-----
    ... private key content for repo1 ...
    -----END OPENSSH PRIVATE KEY-----
```

then you'll need to create a container image to install from private repo like so:
```
- name: repo-name-tools
  applyToJob: false
  applyToWeb: true
  applyToWorkflow: false
  image: "alpine/git:latest"
  env:
  - name: SSH_PRIVATE_KEY
    valueFrom:
      secretKeyRef:
        name: git-deploy-keys
        key: repo-name
  command: ['sh', '-c', 'mkdir -p /root/.ssh && echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa && ssh-keyscan github.com >> /root/.ssh/known_hosts && git clone git@github.com:my-org/my-repo.git --depth 1 --branch main {{.Values.persistence.mountPath}}/my-repo-tools || true']
  volumeMounts:
    - name: galaxy-data
      mountPath: "{{.Values.persistence.mountPath}}"
```

## Configuring main page

Edit `galaxy.configs.tool_conf.xml` and `galaxy.configs.integrated_tool_panel.xml` to change the tool panel and add new sections and tools.

Edit `extraFileMappings./galaxy/server/static/welcome.html.content` to change the html for the welcome page

TODO: we need to make separate files for the xml and html files - having them in yaml is confusing


## Configuring runners

Galaxy is configured to use K8s out-of-the-box to run jobs. They will run on the worker nodes. 

> [!WARNING]
> We haven't tested out GPU-bound jobs yet


You can configure galaxy to use other runners - such as slurm. 
See - [Connecting Galaxy to a Compute Cluster](https://training.galaxyproject.org/training-material/topics/admin/tutorials/connect-to-compute-cluster/tutorial.html)

> [!WARNING]
> We are looking at how to run Slurm into K8s and integrate into Galaxy


## Configuring IAM Setup

We're using oauth2 proxy to handle authentication to IRIS IAM. 
This is because: 

1. Although galaxy offers OIDC support - it only allows access for select providers - see https://galaxyproject.org/authnz/config/oidc/. Adding IRIS IAM authentication would require upstream changes or a fork. 

2. Galaxy does not support authentication client-side (as far as we're aware) - as long as you've got an IAM account and login successfully you can access Galaxy. Oauth proxy enables this and allows us to set up authentication - for example - we can configure it so that only IRIS IAM members that belong to a certain group have access to Galaxy

3. Its seamless! Users will be redirected to IRIS IAM login page before accessing Galaxy.

Other oauth2 proxy config settings can be found here - https://oauth2-proxy.github.io/oauth2-proxy/configuration/overview/. Flags can be passed as `extraArgs`

NOTE: see creating Sops secret about configuring oidc authorization to Galaxy 


## Configuring DNS + certs

To configure what DNS name to use for galaxy - you will need to edit it in 3 places
> [!WARNING] 
> We need to make this easier to change - issue [136](https://github.com/stfc/cloud-deployed-apps/issues/136)

We utilise cert-manager by default for managing certs - and you can see [cert-manager config](./misc.md) on how to configure it to use self-signed or letsencrypt verified certs

```yaml

oauth2-proxy:
  extraArgs:
    # make sure to add this callback to your IAM service config
    redirect-url: "https://my-galaxy.example.com/oauth2/callback" # change dns for redirect

galaxy:
  ingress:
    hosts:
    - host: "my-galaxy.example.com" # change here 
      paths:
        - path: "/"
    tls:
    - hosts:
        - "my-galaxy.example.com" # to enable https - recommended!
      secretName: galaxy-tls
```

# Common Problems 

## 1. Galaxy pods stuck initializing and db init job crashlooping

**Solution**:  If you're using our longhorn chart, you will need to change `longhorn.persistence.migrateable` to `false` since RWX volumes are incompatible with this. Delete the pvc/pv and restart the job and it should work

## 2. Galaxy spins up but reconciliation leads to various pods end up stuck in pending

**Solution**: If you're using ArgoCD and not setting a consistent password for `postgresql.galaxyDatabasePassword` (or `postgresql.galaxyExistingSecret`) it will end up autogenerating a new password every time ArgoCD reconciles the Galaxy chart. 

This will cause the init-db job to fail as it expects the old password to work. This issue can be mitigated by setting a consistent password. This relates to a helm issue around autogenerated secrets https://github.com/galaxyproject/galaxy-helm/issues/112