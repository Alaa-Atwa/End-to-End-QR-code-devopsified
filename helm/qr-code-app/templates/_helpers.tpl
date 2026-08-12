{* notes on this file: *}
{* This file defines reusable snippets (Helm calls them "named templates"), *}
{* so every resource gets consistent labels without retyping them six times, *}
{* {{ .Release.Name }} is the name you give this install (e.g. helm install prod ./qr-code-app → Release.Name is prod) *}
{* this is how the same chart can be installed multiple times under different names without colliding *}
{* .tpl == template *}


{{- define "qr-code-app.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}