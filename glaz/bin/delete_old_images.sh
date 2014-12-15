mysql -u glaz -pglaz glaz -h sql3.webdev.x -sNe 'select report_id, ID from images where updated_at < NOW() - INTERVAL 1 MONTH' | perl -i -p -e 's{(\d+)\s+(\d+)}{curl -X DELETE -f http://web3-tst5.webdev.x:3002/reports/$1/images/$2  }'


