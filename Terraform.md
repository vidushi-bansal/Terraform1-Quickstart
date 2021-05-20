# Terraform - Getting Started

## Provisioning infrastructure through software to achieve consistent and predictable environments.

### Features of Terraform
#### Declarative or Imperative
Imperative: Telling the software exactly what to do, and how to do it.
Declarative: Telling the software to tell what to do. The software has a predined routine or default information regarding management.
Terraform follows a declarative approach to deploying infrastructure as code.

#### Idempotent and Consistency
Idempotent: Being aware of the state. Fr example, if you haven't changed anything in your configuration and you apply it again to the same environment, nothing will change in the environment because your defined configuration matches the reality of the infrastructure that exists.
Consistent: State must be consistent. Same configuration should result the same infrastructure setup in any environment at any time.

#### Push or Pull configuration
Terraform is a push type model. The configuration that terraform has is getting pushed to the target environment.

### Benefits of infrastructure as a code
Automated deployment
Consistent environment
Repeatable process
Reusable components
Documented Architecture