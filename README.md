# az-trial-docs
Documentation for effectively using an Azure 30-day-trial.  

The goal of this repo is to effectively guide new users to Azure to use their trial period and credits to set up their own full stack application -- it's infrastructure, pipelines, and monitoring. 

## Organization

`Days` is the main purpose of this repo, and has links to the other files.  It serves to organized and guide, step by step.  

`Docs` are various mini-guides referenced by Days, so that each day is not too long a file.  This helps keeps the overall filetree of this repo flat.  

`az-trial-infra` is the infrastructure as code (IaC), currently written in bicep, deployable to an Azure account.  

`az-trial-app` will be the actual containerized Next.js frontend and Ruby on Rails backend.  

### notes
- `az-trial-infra` and `az-trial-app` -- I may make these their own repos, but for now it makes for convenient learning and deployments.  These are the deployable 
