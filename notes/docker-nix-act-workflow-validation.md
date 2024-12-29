### **Nix and Act for GitHub Action Validation**

---

### **Introduction**

Working with GitHub Actions can be daunting, especially when you’re trying to test workflows locally. The setup process is often a barrier—especially if you’re trying to avoid cluttering your commit history or introducing broken workflows into your main branch. But with **Nix** and **Act**, you can simplify your local testing environment and streamline validation before pushing your changes upstream.

In this blog post, we’ll walk through:
1. **The problem**: Challenges with testing GitHub Actions locally.
2. **The solution**: How Nix and Act provide a clean, Docker-based workflow.
3. **The epic command**: A breakdown of the single command that will elevate your workflow validation process.

---

### **The Problem**

#### 1. **Act’s Barrier to Entry**
Setting up Act requires careful attention to mimic your remote GitHub setup. Without proper configuration, your local tests might fail, leaving you unsure if the issue lies in the workflow or the environment.

#### 2. **Version Control Overload**
Testing workflows directly in your GitHub repository can lead to a noisy commit history filled with debugging changes. Worse, a misstep could result in broken workflows merged into your main branch.

---

### **The Solution**

By combining **Docker**, **Nix**, and **Act**, you can eliminate the friction of local testing:
- **Docker** provides a lightweight, containerized environment.
- **Nix** ensures consistent tooling and dependency management.
- **Act** runs GitHub Actions workflows locally, mimicking the GitHub-hosted runners.

This setup allows you to:
- Quickly validate workflows without pushing to GitHub.
- Organize your secrets locally for better security.
- Test individual workflows one at a time, ensuring precision.

---

### **The Epic Command**

Let’s jump straight into the one-liner that makes this all possible:

```bash
docker run -it \
  -v ${PWD}:/workspace \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -w /workspace \
  nixos/nix \
  sh -c "nix-env -iA nixpkgs.act && act -P ubuntu-latest=catthehacker/ubuntu:act-latest -W .github/workflows/list-resource-groups.yml"
```

#### **Breaking It Down**
1. **`docker run -it`**  
   - Starts an interactive Docker container.
   - Ensures isolation from your local environment.

2. **`-v ${PWD}:/workspace`**  
   - Mounts your current directory to the `/workspace` directory inside the container, so your workflows are accessible.

3. **`-v /var/run/docker.sock:/var/run/docker.sock`**  
   - Shares your local Docker socket, allowing Act to spin up containers as needed.

4. **`-w /workspace`**  
   - Sets `/workspace` as the working directory inside the container.

5. **`nixos/nix`**  
   - The Docker image, pre-configured with Nix, for seamless package management.

6. **`nix-env -iA nixpkgs.act`**  
   - Installs Act using Nix, ensuring compatibility and avoiding conflicts with your host system.

7. **`act -P ubuntu-latest=catthehacker/ubuntu:act-latest`**  
   - Runs Act, specifying a Docker image (`catthehacker/ubuntu:act-latest`) that closely mirrors GitHub-hosted runners.

8. **`-W .github/workflows/list-resource-groups.yml`**  
   - Specifies the workflow file to test. Replace this with the path to your own workflow file.

---

### **Why This Matters**

#### 1. **Clean Testing Environment**
By running everything inside a container, you avoid polluting your local machine with dependencies or mismatched configurations.

#### 2. **Version Control Sanity**
Since testing happens locally, you keep your Git history clean and reduce the risk of pushing a broken workflow.

#### 3. **Effortless Debugging**
Act mimics GitHub-hosted runners, so you can debug locally with confidence that your fixes will work in production.

---

### **Beyond Act: Makefile Replacement?**

For teams already using Makefiles, Act offers a modern alternative for local application testing:
- Use `act` commands to validate your workflows instead of custom Makefile scripts.
- Benefit from GitHub-hosted runner emulation without additional scripting overhead.

---

### **References**
- [Nix Installation Guide for Docker](https://nixos.org/download/#nix-install-docker)
- [Act Installation and Setup](https://nektosact.com/installation/nix.html)
- [GitHub Repository for Act](https://github.com/nektos/act)

---

Testing GitHub Actions workflows doesn’t have to be painful. With Nix and Act, you can streamline your development process, improve workflow reliability, and keep your main branch pristine. Give it a try and let us know how it transforms your CI/CD workflows!
