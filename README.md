the project consist of 4 parts

1) app folder: which are flutter project that target all platforms (web - andoriod - ios - windows - mac - linux) and this folder contain all protected routes or pages for verfied users.
  note: I have removed folders for web - andoriod - ios - windows - mac - linux in this repository.

2) frontend folder: which contain the web page for website (ailence.ai and ailence.com), it's developed in vue framework with tailwind css.

3) backend folder: which conatin the server files that run in cloudflare worker serverless, it's developed in js.

4) panal folder: which contain the admin panal for controlling users, works, tasks ...etc, it's developed in quasar vue js.

For production deployments, sensitive keys like `MAILTRAP_TOKEN`, Google OAuth credentials and `JWT_SECRET` should be stored using:

```
wrangler secret put <NAME>
```

During local development they can be set under the `[vars]` section of `backend/wrangler.toml`.
