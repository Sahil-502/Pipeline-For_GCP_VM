Current setup is a **Regional external Application Load Balancer** (`lb-2`) with only an **HTTPS (port 443)** frontend, certificate `demo-ssl`, and backend `ddmmoo22`.

Since the **Regional External LB** console doesn’t have a “Redirect HTTP to HTTPS” toggle, you’ll need to **add a second frontend (port 80)** and configure it to **redirect to HTTPS** — but you can’t do this entirely through the UI yet. You’ll use a quick `gcloud` command to add that redirect frontend while keeping your existing LB unchanged.

---

### 🔧 Here’s how to enable HTTP → HTTPS redirection for this LB (`lb-2`):

#### Step 1: Identify key existing components

* **Region:** `us-central1`
* **HTTPS URL map:** automatically created (you can confirm name using below command)
* **HTTPS proxy:** same
* **Frontend IP:** `XX.XX.XX.XX`

You can list them to confirm:

```bash
gcloud compute url-maps list --regions=us-central1
```

You’ll see something like:



```
NAME: lb-2
DEFAULT_SERVICE: backendServices/ddmmoo
```

---

#### Step 2: Create a new **redirect URL map**

This URL map will just tell HTTP traffic to HTTPS Redirect (via YAML)

Create a YAML file for your redirect map

In Cloud Shell:

```bash
cat > redirect-map.yaml <<'EOF'
name: lb-2-http-redirect-map
defaultUrlRedirect:
  httpsRedirect: true
  stripQuery: false
  redirectResponseCode: MOVED_PERMANENTLY_DEFAULT
EOF
```

---

*(This configures a permanent redirect to HTTPS for all HTTP requests.)*

---

#### Step 2: Create the URL map from that file

```bash
gcloud compute url-maps import lb-2-http-redirect-map \
  --source=redirect-map.yaml \
  --region=us-central1
```

✅ You should see something like:

```
Creating URL map...done. 
```

---

#### Step 3: Create the target HTTP proxy

```bash
gcloud compute target-http-proxies create lb-2-http-redirect-proxy \
  --url-map=lb-2-http-redirect-map \
  --region=us-central1
```
---

## ✅ The Command for **Regional External Application LB** (HTTP redirect)

Remove `--network` and `--subnet`, and add `--ip-protocol=TCP` (explicitly required sometimes).

Run this:

```bash
gcloud compute forwarding-rules create lb-2-http-redirect-rule \
  --address=XX.XX.XX.XX \
  --region=us-central1 \
  --load-balancing-scheme=EXTERNAL_MANAGED \
  --target-http-proxy=lb-2-http-redirect-proxy \
  --target-http-proxy-region=us-central1 \
  --ports=80 \
  --network=gke-network \
  --ip-protocol=TCP
```
---

### 🧾 Expected result

```
Created [https://www.googleapis.com/compute/v1/projects/pvt-stage-1/regions/us-central1/forwardingRules/lb-1-http-redirect-rule].
```

Then test:

```bash
curl -I http://XX.XX.XX.XX
```

and you should see:

```
HTTP/1.1 301 Moved Permanently
Location: https://XX.XX.XX.XX/
```

---











