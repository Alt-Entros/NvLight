-- Распознавание конфигов, которые nvim сам не определяет.
-- Нужно, чтобы на них запускались правильные LSP (ansiblels, docker compose, nginx).
vim.filetype.add({
  filename = {
    ["Caddyfile"] = "caddy",
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["compose.yaml"] = "yaml.docker-compose",
    ["playbook.yml"] = "yaml.ansible",
    ["playbook.yaml"] = "yaml.ansible",
    ["site.yml"] = "yaml.ansible",
    ["site.yaml"] = "yaml.ansible",
  },
  pattern = {
    -- Caddy
    [".*%.caddy"] = "caddy",
    ["Caddyfile%..*"] = "caddy",
    -- Docker
    ["docker%-compose%..*%.ya?ml"] = "yaml.docker-compose",
    ["compose%..*%.ya?ml"] = "yaml.docker-compose",
    ["Dockerfile%..*"] = "dockerfile",
    [".*%.[Dd]ockerfile"] = "dockerfile",
    -- Ansible
    [".*/playbooks/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/tasks/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/handlers/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/defaults/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/vars/.*%.ya?ml"] = "yaml.ansible",
    [".*/roles/.*/meta/.*%.ya?ml"] = "yaml.ansible",
    [".*/group_vars/.*%.ya?ml"] = "yaml.ansible",
    [".*/host_vars/.*%.ya?ml"] = "yaml.ansible",
    -- Nginx: любые .conf внутри каталога nginx, sites-available/enabled, snippets
    [".*/nginx/.*%.conf"] = "nginx",
    [".*/nginx/sites%-.*/.*"] = "nginx",
    [".*/nginx/snippets/.*"] = "nginx",
    [".*%.nginx"] = "nginx",
  },
})
