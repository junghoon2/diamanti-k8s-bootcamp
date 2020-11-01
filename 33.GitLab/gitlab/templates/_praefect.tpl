{{/*
Return Praefect's dbSecert secret name
*/}}
{{- define "gitlab.praefect.dbSecret.secret" -}}
{{- default (printf "%s-praefect-dbsecret" .Release.Name) .Values.global.praefect.dbSecret.secret | quote -}}
{{- end -}}

{{/*
Return Praefect's dbSecert secret key
*/}}
{{- define "gitlab.praefect.dbSecret.key" -}}
{{- default "secret" .Values.global.praefect.dbSecret.key | quote -}}
{{- end -}}

{{/*
Return Praefect's database hostname
*/}}
{{- define "gitlab.praefect.psql.host" -}}
{{- coalesce .Values.global.praefect.psql.host (include "gitlab.psql.host" .)  }}
{{- end -}}

{{/*
Return Praefect's database port
*/}}
{{- define "gitlab.praefect.psql.port" -}}
{{- coalesce .Values.global.praefect.psql.port (include "gitlab.psql.port" .) }}
{{- end -}}

{{/*
Return Praefect's database username
*/}}
{{- define "gitlab.praefect.psql.user" -}}
{{- default "praefect" .Values.global.praefect.psql.user }}
{{- end -}}

{{/*
Return Praefect's database name
*/}}
{{- define "gitlab.praefect.psql.dbName" -}}
{{- default "praefect" .Values.global.praefect.psql.dbName }}
{{- end -}}

{{/*
Return the praefect secret name
Preference is local, global, default (`praefect-secret`)
*/}}
{{- define "gitlab.praefect.authToken.secret" -}}
{{- coalesce .Values.global.praefect.authToken.secret (printf "%s-praefect-secret" .Release.Name) | quote -}}
{{- end -}}

{{/*
Return the praefect secret key
Preference is local, global, default (`token`)
*/}}
{{- define "gitlab.praefect.authToken.key" -}}
{{- coalesce .Values.global.praefect.authToken.key "token" | quote -}}
{{- end -}}
