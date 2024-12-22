# az-trial-docs
Documentation for effectively using an Azure 30-day-trial.  

This repo is a guide for developers or business owners interested in the Azure ecosystem.  

The goal is to set up a scalable and secure full stack application -- it's infrastructure, pipelines, and monitoring -- in 30 days or less.  

**Scalable** -- from dev environment to MVP, the app architecture is ready to adapt to the needs of a quickly growing business and its teams.  
**Secure** -- is an ideal, yet this documentation does its best to reference both Microsoft and industry best practices.  

## Repo Organization

`Days` is the main purpose of this repo, and has links to the other files.  It serves to organized and guide, step by step.  

`Docs` are various mini-guides referenced by Days, so that each day is not too long a file.  This helps keeps the repo flat and manageable.  

`az-trial-infra` is the infrastructure as code (IaC), currently written in bicep, deployable to an Azure account.  

`az-trial-app` will be the actual containerized Next.js frontend and Ruby on Rails backend.  

### notes
- `az-trial-infra` and `az-trial-app` -- I may make these their own repos, but for now it makes for convenient learning and deployments.  These are the deployable 
