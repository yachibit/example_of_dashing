# coding: utf-8
require 'rubygems'
require 'active_support/all'
require "tiny_tds"
require "date"

SCHEDULER.every '10s' do
  points = []

  client = TinyTds::Client.new( :username => 'sa',
                                :password => 'sfadmin@2012',
                                :host => 'f01107800',
                                :dataserver => '10.148.65.134',
                                :database => 'ProgressManagementDB'
                              )

  sql = "SELECT Top 10 convert(Date, convert(varchar(10), 終了日時, 111)) as date,
                count(*) as count
        FROM 作業工程管理テーブル
        WHERE 作業工程コード = 'A06'
        GROUP BY convert(Date, convert(varchar(10), 終了日時, 111))
        ORDER BY date desc;"

  result = client.execute(sql)

  result.each do |row|
    # Dashingで使われるGraphing tool「Rickshaw」は、
    # X軸にUnix Time形式の値を渡す必要がある
    points << { x: DateTime.parse(row["date"]).to_i, y: row["count"] }
  end

  send_event('completed_per_days', points: points.reverse)
end