#!/bin/bash
#有効期限の切れた避難者情報を論理削除する

PATH=$PATH:/usr/local/bin
export PATH

#cd /path/to/deploy
cd /home/apl/develop/lgdpf/LGDPF/batch

rails runner Batches::PeopleDestroy.execute -e production >> ../log/people_destroy.log 2>&1

exit 0
