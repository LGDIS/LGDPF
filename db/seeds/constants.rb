# -*- coding:utf-8 -*-

# 性別
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'sex', text: '男性',  value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'sex', text: '女性',  value: '2', _order: '2')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'sex', text: 'その他', value: '3', _order: '3')
# レコード保持期間
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'expiry_date', text: '約 1 か月（30 日）後', value: '30', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'expiry_date', text: '約 2 か月（60 日）後', value: '60', _order: '2')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'expiry_date', text: '約 3 か月（90 日）後', value: '90', _order: '3')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'expiry_date', text: '約 6 か月（180 日）後', value: '180', _order: '4')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'expiry_date', text: '約 1 年（360 日）後', value: '360', _order: '5')
# 安否状況
Constant.create(kind1: 'TD', kind2: 'notes', kind3: 'status', text: '指定なし', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'notes', kind3: 'status', text: '情報を探している', value: '2', _order: '2')
Constant.create(kind1: 'TD', kind2: 'notes', kind3: 'status', text: '私が本人である', value: '3', _order: '3')
Constant.create(kind1: 'TD', kind2: 'notes', kind3: 'status', text: 'この人が生きているという情報を入手した', value: '4', _order: '4')
Constant.create(kind1: 'TD', kind2: 'notes', kind3: 'status', text: 'この人を行方不明と判断した理由がある', value: '5', _order: '5')
#
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'status', text: '指定なし', value: "", _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'status', text: '指定なし', value: '1', _order: '2')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'status', text: '誰かがこの人物についての情報を求めています', value: '2', _order: '3')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'status', text: 'この人からの投稿メッセージがあります', value: '3', _order: '4')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'status', text: 'この人が生きているという情報を入手した人がいます', value: '4', _order: '5')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'status', text: 'この人を行方不明者として報告した人がいます', value: '5', _order: '6')
# 市内・市外区分
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'in_city_flag', text: '市内', value: "1", _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'in_city_flag', text: '市外', value: '0', _order: '2')
# 避難所
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'shelter_name', text: '石巻小学校', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'shelter_name', text: '石巻中学校', value: '2', _order: '2')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'shelter_name', text: '市立体育館', value: '3', _order: '3')
# 避難状況
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'refuge_status', text: '避難済', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'refuge_status', text: '未避難', value: '2', _order: '2')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'refuge_status', text: '避難所を既に退去済', value: '3', _order: '3')
# 負傷
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'injury_flag', text: '有', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'injury_flag', text: '無', value: '0', _order: '2')
# アレルギー
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'allergy_flag', text: '有', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'allergy_flag', text: '無', value: '0', _order: '2')
# 妊娠である
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'pregnancy', text: '妊娠中', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'pregnancy', text: '該当しない', value: '0', _order: '2')
# 乳幼児である
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'baby', text: '乳児', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'baby', text: '幼児', value: '2', _order: '2')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'baby', text: '該当しない', value: '0', _order: '3')
# 要介護者である
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'upper_care_level_three', text: '非該当', value: '00', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'upper_care_level_three', text: '要支援', value: '01', _order: '2')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'upper_care_level_three', text: '要介護1', value: '02', _order: '3')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'upper_care_level_three', text: '要介護2', value: '03', _order: '4')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'upper_care_level_three', text: '要介護3', value: '04', _order: '5')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'upper_care_level_three', text: '要介護4', value: '05', _order: '6')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'upper_care_level_three', text: '要介護5', value: '06', _order: '7')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'upper_care_level_three', text: 'みなし非該当', value: '91', _order: '8')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'upper_care_level_three', text: 'みなし要支援', value: '92', _order: '9')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'upper_care_level_three', text: 'みなし要介護', value: '93', _order: '10')
# 一人暮らし高齢者（65歳以上）である
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'elderly_alone', text: '該当する', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'elderly_alone', text: '該当しない', value: '0', _order: '2')
# 高齢者世帯（夫婦共に65歳以上）である
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'elderly_couple', text: '該当する', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'elderly_couple', text: '該当しない', value: '0', _order: '2')
# 寝たきり高齢者である
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'bedridden_elderly', text: '該当する', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'bedridden_elderly', text: '該当しない', value: '0', _order: '2')
# 認知症高齢者である
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'elderly_dementia', text: '該当する', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'elderly_dementia', text: '該当しない', value: '0', _order: '2')
# 療育手帳所持者である
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: '最重度', value: '01', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: 'OA', value: '02', _order: '2')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: 'A1', value: '03', _order: '3')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: '1度', value: '04', _order: '4')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: '重度', value: '05', _order: '5')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: 'A', value: '06', _order: '6')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: 'A2', value: '07', _order: '7')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: '2度', value: '08', _order: '8')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: '中度', value: '09', _order: '9')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: 'B', value: '10', _order: '10')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: 'B1', value: '11', _order: '11')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: '3度', value: '12', _order: '12')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: '軽度', value: '13', _order: '13')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: 'C', value: '14', _order: '14')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: 'B2', value: '15', _order: '15')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: '4度', value: '16', _order: '16')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'rehabilitation_certificate', text: 'なし', value: '99', _order: '17')
# 身体障害者手帳所持者である
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'physical_disability_certificate', text: '1級', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'physical_disability_certificate', text: '2級', value: '2', _order: '2')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'physical_disability_certificate', text: '該当しない', value: '0', _order: '3')

Constant.create(kind1: 'TD', kind2: 'people', kind3: 'invalid_reason', text: 'この記録に関する最新情報は不要です。', value: 'do_not_want_anymore', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'invalid_reason', text: 'この記録が原因でスパムを受信したから', value: 'spam_received', _order: '2')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'invalid_reason', text: 'この記録がスパム情報だから', value: 'record_is_spam', _order: '3')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'invalid_reason', text: 'この記録が目的を果たしたから', value: 'served_its_purpose', _order: '4')
# 家族も無事
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'family_well', text: '無事', value: '1', _order: '1')
Constant.create(kind1: 'TD', kind2: 'people', kind3: 'family_well', text: '無事か確認できていない', value: '0', _order: '2')

