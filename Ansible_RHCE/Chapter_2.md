Installation of Ansible

-- Ansible-navigator
	Python based automation tool. Revise the Container's from RHCSA.
	Install this on Control node. 

We will be pulling the image from the registry. 
ghcr -- Github Container Regitry. It contains
	Files, binaries, dependecies, ansible-core. 

How deployment happens:
	Ansible-navigator uses container to connect with Managed hosts from control node. 

-------------- Revise the containers from RHCSA-------------
Containers are an efficient way to reuse hosted applications and to make them portable.
Containers can be easily moved from one environment to another, such as from development to
production. You can save multiple versions of a container and quickly access each one as needed.

Contianer Management Tools

• podman manages containers and container images.
• skopeo inspects, copies, deletes, and signs images.
• buildah creates container images.

A container image is a static file that contains codified steps, and it serves as a blueprint to create containers

Default install on RHEL podman
// podman --version


--Registry update/addition

vim /etc/containers/registries.conf
//unqualified registry

podman ps -- show active containers

podman ps -a --show all the containers

podman login registry name //for pulling image from private registry
----------------------------------RHCSA-----------------------------------

Previosly Ansible that was used was Ansible playbook
the change of dependecies and requirement for certain env would cause issues wih deployment. 
which demanded the change and use of containers. 


Control Node -- Main Machine
Managed Hosts -- Target/Client

Inventory -- Host List

ansible.cfg -- File created to manage the behaviour of ansible.
		//If ansible.cfg will not be created the ansible use default info available in the image cfg file.

ansible-navigator.yaml --> IaC navigator work

Playbook --> What task to perform. with .yaml/yml format.

 In enterprise enviroment, we will not use root. 
Create a common user student. 


Use SSH -- with key based auth. 

ssh -cpy-id student@IP  //export the public keys to servers. 

Repo's is required on the server for practical scenrio.
-- /etc/hosts --> local DNS
IP FQDN hostname

Offline Repo --- do not have ansible navigator.
Online --download the ansible navigator

for local repo, we will install the python package using pip. Since ansible is python based, 
on offline machine we can install the pip to install ansible. 


