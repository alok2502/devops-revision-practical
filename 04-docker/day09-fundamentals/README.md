# Day 9 — Docker Fundamentals + Internals

## Proved "a container is just a process"
- nginx = PID 1 INSIDE the container, but PID 3827 on the HOST (same process, 2 PIDs).
- `docker inspect --format '{{.State.Pid}}'` gives the host PID.
- /proc/<hostpid>/ns/ shows the namespace symlinks (pid/net/mnt/uts/ipc/cgroup/user).
  Different namespace IDs than host PID 1 = isolation, made countable.
- Container escape = breaking out of those namespace boundaries to the host kernel.

## Key concepts
- Image = read-only layered template. Container = image + thin writable layer.
- `docker run` = new namespaces (what it sees) + cgroup (what it uses) around a process.
- Port mapping: -p 8080:80 = host 8080 -> container 80 (seen in `docker ps` PORTS).
- Minimal images (nginx) lack tools like `ps` ON PURPOSE (smaller attack surface).
  Debug from the host or via /proc, not by assuming tools exist inside.

## Built my own image
- Dockerfile: FROM -> WORKDIR -> COPY -> EXPOSE -> CMD (CMD process becomes PID 1).
- `docker build -t myapp:v1 .` builds layer by layer (BuildKit); layers are cached.
- myapp:v1 = 177MB despite tiny code — base image dominates. Day 11 = shrink it.

## Security preview (reasoned out)
- `USER x` in Dockerfile = don't run as root INSIDE (same user namespace).
- userns-remap / rootless = container-root maps to unprivileged host UID (diff namespace).
