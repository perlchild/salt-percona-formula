{% from "percona/map.jinja" import percona_settings with context %}

{{ percona_settings.config_directory }}:
  file.directory:
    - makedirs: True
    - user: root
    - group: root
    - require_in:
      - pkg: percona_client

{% if percona_settings.reload_on_change %}
include:
  - .service
{% endif %}

{% if 'config' in percona_settings and percona_settings.config is mapping %}
{%   for file, content in percona_settings.config.iteritems() %}
{%     if file == 'my.cnf' %}
{%       set filepath = percona_settings.my_cnf_path %}
{%     else %}
{%       set filepath = percona_settings.config_directory + '/' + file %}
{%     endif %}
{{ filepath }}:
  file.managed:
    - user: root
    - group: root
    - mode: 0644
    - source: salt://percona/files/mysql.cnf.j2
    - template: jinja
    - context:
        config: {{ content |default({}) }}
{%     if percona_settings.reload_on_change %}
    - watch_in:
      - service: percona_svc
{%     endif %}
{%   endfor %}
{% endif %}
