# az-trial-docs
Documentation for effectively using an Azure 30-day-trial.  

This repo is a guide for developers or business owners interested in building their startup on Azure.  

The goal is to set up a scalable and secure full stack application -- it's infrastructure, pipelines, and monitoring -- in 30 days or less.  

**Scalable** -- from dev environment to MVP, the app architecture is ready to adapt to the needs of a quickly growing business and its teams.  
**Secure** -- is an ideal, yet this documentation does its best to reference both Microsoft and industry best practices.  

## Repo Organization
`days` is the main purpose of this repo, and has links to the other files and repos.  It serves as a step by step guide for startups.   

`docs` various mini-guides referenced by Days, so that each day is not too long a file.  This helps keeps the repo flat and manageable.  

## Project Organization (related repos)

`az-trial-infra` is the infrastructure as code (IaC) repo, currently written in bicep, deployable to an Azure account.  

`az-trial-app` is the containerized Next.js frontend repo.

`az-trial-api` is the containerized Ruby on Rails backend repo.

