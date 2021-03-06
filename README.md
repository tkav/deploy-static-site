# Cloudfront Static Site

Quickly deploy a static site to AWS using Terraform, S3 and CloudFront (without a custom domain).

To deploy a static site quickly to CloudFront with a custom domain, please use [tkav/cloudfront-static-site](https://github.com/tkav/cloudfront-static-site).

# Usage

This is a template repo! Click [`Use this template`](https://github.com/tkav/cloudfront-static-site/generate) before continuing on.

[![Use this template](https://i.imgur.com/LYtQFxY.png)](https://github.com/tkav/cloudfront-static-site/generate)

Then [clone](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) and open this repo.

## Requirements
- Terraform (>v1.0.0)

1. Update `variables.sh` and load environmental variables:
```
source variables.sh
```

2. Replace and add your static website contents to `src` folder. The distribution will look for `index.html` and `404.html` pages. Make sure you have those.

3. Deploy your site:
```
make deploy_site
```

When completed, something like the following will be outputted:
```
Outputs:

cloudfront_domain = "dlimer79nfhej.cloudfront.net"
```

Your site is now available at the `cloudfront_domain`.


## Updating Site Content

If changes are made in the `src` folder, run the following to upload the changes to your S3 bucket:
```
make upload_site
```
This will also be run when contents are pushed to the repo with changes in the `src` folder.


## Destroying the Site

To destroy everything to do with this deployment:
```
make destroy
```
And confirm the steps.
S3 buckets, Cloudfront distributions and certificates will be deleted!
