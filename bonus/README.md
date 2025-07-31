# GitLab + ArgoCD Setup

## Setup VM

vagrant up
vagrant ssh bonus


## Inside the VM

cd /vagrant/scripts
chmod -x launch.sh install.sh
bash `install.sh`
exit


## Reconnect to the VM

vagrant ssh bonus
cd /vagrant/scripts
bash `launch.sh` # This may take ~15min


## On your host machine

Add this line to your `/etc/hosts` file:

192.168.56.130 gitlab.local


## Once `launch.sh` is done

1. Open `http://gitlab.local` in your browser.  
2. Create a project named `iot` in the `root` namespace.  
3. Make it public.  
4. Add your SSH key.  
5. Clone the repo, add the `dev` folder, commit and push (use same GitLab user/password).

## Port forward ArgoCD in the VM

kubectl port-forward --address 192.168.56.130 svc/argocd-server 8080:80 -n argocd


## Access ArgoCD

Open in your browser:

http://192.168.56.130:8080


Once everything is synced and healthy, the app will be available at:

http://192.168.56.130


## Update image

In the `iot` repo, update `deployment.yaml`:

```yaml
image: wil42/playground:v1
# change to:
image: wil42/playground:v2
```

Check ArgoCD; once synced again, refresh the app to see the new version.