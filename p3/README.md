# Part 3: K3d and Argo CD

## Requirement
- Docker
- k3d
- kubectl
- argo cd
- github account
- docker hub account
- webserver image to test the deployment, it has at least two version
    

## Project Goal
- Use Argo CD to deploy the IoT application to the k3d cluster.
- Argo will watch github repository when push event, it will automatically deploy and update the application.
- Flow:
    - First app is deploy with image v1
    - Change image to v2 and push to github
    - Argo CD will detect the change and deploy the application with image v2
    - Check if the application is deployed with image v2
    - If wrong version, rollback to image last deploy