# GitHub Actions Signing Secret Configuration Guide

This guide details the exact format and configuration required for the container signing key in your GitHub repository.

---

## 1. Where to Add the Secret in GitHub

1. Navigate to your repository settings:  
   👉 **`https://github.com/RowdyRagamuffin/surface-andree/settings/secrets/actions`**
2. Click the green button **New repository secret** (or edit the existing secret).
3. Secret Name:
   ```
   SIGNING_SECRET
   ```
   *(Note: The workflow also supports `COSIGN_PRIVATE_KEY`).*

---

## 2. Exact Raw Value for `SIGNING_SECRET`

Copy the block below **exactly as shown**. Do **not** add quotes around it. Do **not** add extra spaces before or after:

```text
-----BEGIN ENCRYPTED SIGSTORE PRIVATE KEY-----
eyJrZGYiOnsibmFtZSI6InNjcnlwdCIsInBhcmFtcyI6eyJOIjo2NTUzNiwiciI6
OCwicCI6MX0sInNhbHQiOiJ2c1pZa1Z2SlpTYjRVNktUQnlTT3k0KzFBdjd2TjVt
bnFqY3YveWpFM3hBPSJ9LCJjaXBoZXIiOnsibmFtZSI6Im5hY2wvc2VjcmV0Ym94
Iiwibm9uY2UiOiJINlVXWUQ4OW1HM08wbEFyNmh1NXhweFpXT29BdWQ0QiJ9LCJj
aXBoZXJ0ZXh0IjoidlN0WmQxT2w2VkdoSUdMR3VHajlLeFM1aE1BUU5PUTg4eTFI
RFkraFB0RWFVdmpQYjBCb2l4aHk4SHQvM0pCQnlRbFE0WU9oRnAzMzhsY0xMbzNR
cU5uNm9zRE40ZnRNcmpOU2YrKzE0eFBMTkF1TjFIU08rbXJzNXQ1d1U3R1VOdjQx
eURjTE5nbHVIVDEweXFMMklCanB4WE8zNFdzUGJWQXBtVzRGOWx0VEpkN3ZmTDRt
MEJOUnNGL3FGZldEWXpYcStGRUV3K3Irc0E9PSJ9
-----END ENCRYPTED SIGSTORE PRIVATE KEY-----
```

---

## 3. Matching Public Key (`cosign.pub`)

This file is already committed in the root of your repository:

```text
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEGH9PxBoL0vcTixe7mD2ID4I3G/PM
5jI0osfh1nzol8+vwagLSH46FtkgIT2rpWIVqMmuPZIzQp4grl3CySZ+FA==
-----END PUBLIC KEY-----
```

---

## 4. Alternative: Set Secret via GitHub CLI (One-Liner)

If you have the `gh` CLI logged in, you can set the secret directly without web browser or clipboard interference:

```bash
gh secret set SIGNING_SECRET --repo RowdyRagamuffin/surface-andree --body "-----BEGIN ENCRYPTED SIGSTORE PRIVATE KEY-----
eyJrZGYiOnsibmFtZSI6InNjcnlwdCIsInBhcmFtcyI6eyJOIjo2NTUzNiwiciI6
OCwicCI6MX0sInNhbHQiOiJ2c1pZa1Z2SlpTYjRVNktUQnlTT3k0KzFBdjd2TjVt
bnFqY3YveWpFM3hBPSJ9LCJjaXBoZXIiOnsibmFtZSI6Im5hY2wvc2VjcmV0Ym94
Iiwibm9uY2UiOiJINlVXWUQ4OW1HM08wbEFyNmh1NXhweFpXT29BdWQ0QiJ9LCJj
aXBoZXJ0ZXh0IjoidlN0WmQxT2w2VkdoSUdMR3VHajlLeFM1aE1BUU5PUTg4eTFI
RFkraFB0RWFVdmpQYjBCb2l4aHk4SHQvM0pCQnlRbFE0WU9oRnAzMzhsY0xMbzNR
cU5uNm9zRE40ZnRNcmpOU2YrKzE0eFBMTkF1TjFIU08rbXJzNXQ1d1U3R1VOdjQx
eURjTE5nbHVIVDEweXFMMklCanB4WE8zNFdzUGJWQXBtVzRGOWx0VEpkN3ZmTDRt
MEJOUnNGL3FGZldEWXpYcStGRUV3K3Irc0E9PSJ9
-----END ENCRYPTED SIGSTORE PRIVATE KEY-----"
```

---

## 5. What Causes `Failed to run cosign public-key: Error: invalid pem block`?

1. **Empty Secret:** If the secret name in GitHub does not match what the workflow expects (`SIGNING_SECRET`), GitHub Actions leaves the environment variable empty. When Cosign reads an empty input, it outputs `Error: invalid pem block`.
2. **Accidental Quotes:** If the secret is pasted with wrapping quotation marks (`"` or `'`), Cosign fails to parse the PEM header.
3. **Windows CRLF Line Endings:** If pasted from certain Windows browsers, carriage returns (`\r`) can be embedded into the secret value. The updated workflow automatically cleans these before execution.
