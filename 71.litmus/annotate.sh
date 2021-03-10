# chaos 실행 할 application에 먼저 annotate 적용 
# deploy 이름 변경

kubectl annotate deploy/nginx01 litmuschaos.io/chaos="true" -n nginx