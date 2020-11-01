{{/*
Return the default praefect storage line for gitlab.yml
*/}}
{{- define "gitlab.praefect.storages" -}}
default:
  path: /var/opt/gitlab/repo
  gitaly_address: tcp://{{ template "gitlab.praefect.serviceName" . }}:{{ .Values.global.gitaly.service.externalPort }}
{{- end -}}


{{/*
Return the resolvable name of the praefect service
*/}}
{{- define "gitlab.praefect.serviceName" -}}
{{ $.Release.Name }}-praefect
{{- end -}}


{{/*
Return a list of Gitaly pod names
*/}}
{{- define "gitlab.praefect.gitalyPodNames" -}}
{{ range until ($.Values.global.praefect.gitalyReplicas | int) }}{{ printf "%s-gitaly-%d" $.Release.Name . }},{{- end}}
{{- end -}}
