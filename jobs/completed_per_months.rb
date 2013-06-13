# coding: utf-8
require 'rubygems'
require 'active_support/all'
require "tiny_tds"
require "date"

SCHEDULER.every '10s' do
  completed_counts = Hash.new({ value: 0 })
  completed_this_month, completed_last_month, unstarted = 0, 0, 0 

  client_completed_months = TinyTds::Client.new( :username => 'sa',
                                :password => 'sfadmin@2012',
                                :host => 'f01107800',
                                :dataserver => '10.148.65.134',
                                :database => 'ProgressManagementDB'
                              )
  client_unstarted = TinyTds::Client.new( :username => 'sa',
                                :password => 'sfadmin@2012',
                                :host => 'f01107800',
                                :dataserver => '10.148.65.134',
                                :database => 'ProgressManagementDB'
                              )

  sql_completed_months =  "SELECT TOP 2 LEFT(CONVERT(DATE, CONVERT(nvarchar, 終了日時, 111)),7) as date,
                                  count(*) as count
                          FROM 作業工程管理テーブル
                          WHERE 作業工程コード = 'A06'
                          GROUP BY LEFT(CONVERT(DATE, CONVERT(nvarchar, 終了日時, 111)),7)
                          ORDER BY date desc;"
  sql_unstarted = "SELECT count(*) as count
                  FROM 作業工程管理テーブル
                  WHERE 作業工程コード = 'A06' and
                        終了日時 is null;"

  result_completed_months = client_completed_months.execute(sql_completed_months)
  result_unstarted = client_unstarted.execute(sql_unstarted)



  result_completed_months.each do |row|
    case row["date"]
    # 当月
    when Date.today.to_s[0, 7]
      completed_this_month = row["count"]
    # 昨月
    when Date.today.prev_month.to_s[0, 7]
      completed_last_month = row["count"]
    end
  end

  result_unstarted.each do |row|
    unstarted = row["count"]
  end

  completed_counts['前月'] = { label: '前月', value: completed_this_month }
  completed_counts['当月'] = { label: '当月', value: completed_last_month }

  completed_counts['処理対象'] = { label: '処理対象', value: unstarted }

  send_event('completed_per_months', { items: completed_counts.values })
end