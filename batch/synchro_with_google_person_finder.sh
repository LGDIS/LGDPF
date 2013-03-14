#!/bin/bash

# Rails.rootに遷移する
cd /path/to/deploy

#GooglePersonFinderから「石巻市」のデータを取り込む
rails runner Batches::ImportGooglePersonFinder.execute -e production >> log/import_google_person_finder.log 2>&1

#GooglePersonFinderへデータをアップロードする
rails runner Batches::ExportGooglePersonFinder.execute -e production >> log/export_google_person_finder.log 2>&1

exit 0
