#!/bin/bash
#有効期限の切れた避難者情報を論理削除する

# Rails.rootに遷移する
cd /path/to/deploy

rails runner Batches::PeopleDestroy.execute -e production >> log/people_destroy.log 2>&1

exit 0
