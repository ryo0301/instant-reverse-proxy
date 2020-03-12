const path = require('path');
const fs = require('fs');
const mustache = require('mustache');
const yaml = require('js-yaml');

const tmpl_dir = path.resolve(__dirname, '../templates/');

const host = process.env.HOST_NAME;
const domain = process.env.HOSTED_ZONE_DOMAIN;
const caddy_url = process.env.CADDY_DL_URL;
const timer = process.env.SHUTDOWN_TIMER_HOUR;
const remote_port = process.env.UPSTREAM_PORT;

const files_meta = [
  {
    filename: 'suicide.sh',
    owner: 'root:root',
    path: '/usr/local/bin/suicide.sh',
    permissions: '0755',
    view: {
      timer: timer,
    },
  },
  {
    filename: 'crontab',
    owner: 'root:root',
    path: '/etc/crontab',
    permissions: '0644',
    view: {
    },
  },
  {
    filename: 'caddy.service',
    owner: 'root:root',
    path: '/etc/systemd/system/caddy.service',
    permissions: '0644',
    view: {
    },
  },
  {
    filename: 'Caddyfile',
    owner: 'root:root',
    path: '/etc/caddy/Caddyfile',
    permissions: '0644',
    view: {
      host: host,
      domain: domain,
      remote_port: remote_port,
    },
  },
  {
    filename: 'route53-upsert.sh',
    owner: 'root:root',
    path: '/var/lib/cloud/scripts/per-boot/route53-upsert.sh',
    permissions: '0755',
    view: {
      host: host,
      domain: domain,
    },
  },
  {
    filename: 'bootstrap.sh',
    owner: 'root:root',
    path: '/var/lib/cloud/scripts/per-instance/bootstrap.sh',
    permissions: '0755',
    view: {
      host: host,
      domain: domain,
      caddy_url: caddy_url,
    },
  },
];


const cc = {
  repo_upgrade: 'all',
  locale: 'ja_JP.UTF-8',
  timezone: 'Asia/Tokyo',
  write_files: [],
};

for (const meta of files_meta) {
  const tmpl_path = path.join(tmpl_dir, meta.filename);
  const template = fs.readFileSync(tmpl_path, 'utf-8');
  const content = mustache.render(template, meta.view);
  const b64c = Buffer.from(content).toString('base64');
  const file = {
    encoding: 'b64',
    content: b64c,
    owner: meta.owner,
    path: meta.path,
    permissions: meta.permissions
  };
  cc.write_files.push(file);
}

console.log("#cloud-config\n\n" + yaml.safeDump(cc));
