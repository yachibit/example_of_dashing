# coding: utf-8 
require 'rubygems'
require 'active_support/all'
require "tiny_tds"
require "date"

SCHEDULER.every '10s' do
  completed_1, completed_2, completed_3, completed_4, completed_5  = 0, 0, 0, 0, 0
  goal_1, goal_2, goal_3, goal_4, goal_5 = 0, 0, 0, 0, 0

  client_completed = TinyTds::Client.new( :username => 'sa',
                                :password => 'sfadmin@2012',
                                :host => 'f01107800',
                                :dataserver => '10.148.65.134',
                                :database => 'ProgressManagementDB'
                              )
  client_goal = TinyTds::Client.new( :username => 'sa',
                                :password => 'sfadmin@2012',
                                :host => 'f01107800',
                                :dataserver => '10.148.65.134',
                                :database => 'ProgressManagementDB'
                              )

  sql_completed = "SELECT 作業工程コード as code,
        count(*) as count
        FROM 作業工程管理テーブル
        WHERE 終了日時 >= \'#{Date.today}\' and
              終了日時 < \'#{Date.today.tomorrow}\'
        GROUP BY 作業工程コード
        ORDER BY 作業工程コード;"
  sql_goal = "SELECT 作業工程コード as code,
        目標作業件数 as goal
        FROM 日次目標作業件数テーブル
        ORDER BY 作業工程コード;"

  result_completed = client_completed.execute(sql_completed)
  result_goal = client_goal.execute(sql_goal)

  result_completed.each do |row|
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

  result_goal.each do |row|
    case row["code"]
    when 'A02'
      goal_1 = row["goal"] unless row["goal"].nil?
    when 'A03'
      goal_2 = row["goal"] unless row["goal"].nil?
    when 'A04'
      goal_3 = row["goal"] unless row["goal"].nil?
    when 'A05'
      goal_4 = row["goal"] unless row["goal"].nil?
    when 'A06'
      goal_5 = row["goal"] unless row["goal"].nil?
    end
  end

  send_event("completed_1",   { value: completed_1, max: goal_1, moreinfo: goal_1 })
  send_event("completed_2",   { value: completed_2, max: goal_2, moreinfo: goal_2 })
  send_event("completed_3",   { value: completed_3, max: goal_3, moreinfo: goal_3 })
  send_event("completed_4",   { value: completed_4, max: goal_4, moreinfo: goal_4 })
  send_event("completed_5",   { value: completed_5, max: goal_5, moreinfo: goal_5 })
end