# coding: utf-8
require 'rubygems'
require 'active_support/all'
require "tiny_tds"
require "date"

SCHEDULER.every '10s' do
  checking_counts = Hash.new({ value: 0 })
  completed_1, completed_2, completed_3, completed_4, completed_5  = 0, 0, 0, 0, 0

  client = TinyTds::Client.new( :username => 'sa',
                                :password => 'sfadmin@2012',
                                :host => 'f01107800',
                                :dataserver => '10.148.65.134',
                                :database => 'ProgressManagementDB'
                              )

  sql = "SELECT 作業工程コード as code,
                count(*) as count
        FROM 作業工程管理テーブル
        WHERE 拡張項目1 = 'B00' or
              拡張項目1 = 'C00'
        GROUP BY 作業工程コード
        ORDER BY 作業工程コード;"

  result = client.execute(sql)

  result.each do |row|
    case row["code"]
    when 'A02'
      completed_1 = row["count"]
    when 'A03'
      completed_2 = row["count"]
    when 'A04'
      completed_3 = row["count"]
    when 'A05'
      completed_4 = row["count"]
    when 'A06'
      completed_5 = row["count"]
    end
  end

  checking_counts['一次チェック'] = { label: '一次チェック', value: completed_1 }
  checking_counts['スキャン'] = { label: 'スキャン', value: completed_2 }
  checking_counts['登録'] = { label: '登録', value: completed_3 }
  checking_counts['二次チェック１'] = { label: '二次チェック１', value: completed_4 }
  checking_counts['二次チェック２'] = { label: '二次チェック２', value: completed_5 }

  send_event('checking', { items: checking_counts.values })
end