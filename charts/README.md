# Instructions for publishing charts

## For each of the chart repos:

- `helm dependency update` - Updates the dependencies (and a lock file if present)
- `helm dependency build .` - Builds the dependencies
- `helm package .`
- Move all the `*.tgz` into a common folder

## To generate the `index.yaml`

- In the common folder where all the `*.tgz have been moved`
  - `helm repo index . --url https://charts.mrsharky.com/`
