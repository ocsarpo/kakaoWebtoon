require 'sinatra'
require 'sinatra/reloader'
require 'httparty'
require 'json'
require 'data_mapper'
require './webtoon'

set :bind, '0.0.0.0'

get '/' do
  erb :index
end

get '/today_arr' do
  # 1. url 만들기
  time = Time.now.to_i
  week = DateTime.now.strftime("%a").downcase
  url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/#{week}?timeStamp=#{time}"
  # 2. 해당 url에 요청, 데이터 받음
  response = HTTParty.get(url)
  # 3. JSON형식으로 날아온 데이터를 Hash형식으로 바꾼다
  doc = JSON.parse(response.body)
  # 4. 키를 이용해서 원하는 데이터만 수집
  # 우리가 원하는 데이터 : 제목, 이미지, 볼 수 있는 링크(보게되면 불법), 웹툰 소개, 평점
  # 평점: averageScore,
  # 제목: title,
  # 소개: introduction
  # 이미지: appThumbnailImage["url"]
  # 링크: http://webtoon.daum.net/webtoon/view/#{nickname}
  @webtoons = Array.new
  doc["data"].each do |webtoon|
    toon = {
      name: webtoon["title"],
      desc: webtoon["introduction"],
      score: webtoon["averageScore"], # 소수점 반올림 추가
      img_url: webtoon["appThumbnailImage"]["url"],
      url: "http://webtoon.daum.net/webtoon/view/#{webtoon['nickname']}"
    }
    @webtoons << toon
  end
  # 5. view에서 보여주기 위해 @webtoons 에 담는다

  erb :webtoon_list_arr
end

get '/week_arr/:day' do
  day = params[:day]
  url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/#{day}"
  response = HTTParty.get(url)
  doc = JSON.parse(response.body)
  @webtoons = Array.new
  doc["data"].each do |webtoon|
    toon = {
      name: webtoon["title"],
      desc: webtoon["introduction"],
      score: webtoon["averageScore"], # 소수점 반올림 추가
      img_url: webtoon["appThumbnailImage"]["url"],
      url: "http://webtoon.daum.net/webtoon/view/#{webtoon['nickname']}"
    }
    @webtoons << toon
  end

  erb :day_arr
end

get '/today' do
  # 1. url 만들기
  time = Time.now.to_i
  week = DateTime.now.strftime("%a").downcase
  url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/#{week}?timeStamp=#{time}"
  # 2. 해당 url에 요청, 데이터 받음
  response = HTTParty.get(url)
  # 3. JSON형식으로 날아온 데이터를 Hash형식으로 바꾼다
  doc = JSON.parse(response.body)
  # 4. 키를 이용해서 원하는 데이터만 수집
  # 우리가 원하는 데이터 : 제목, 이미지, 볼 수 있는 링크(보게되면 불법), 웹툰 소개, 평점
  # 평점: averageScore,
  # 제목: title,
  # 소개: introduction
  # 이미지: appThumbnailImage["url"]
  # 링크: http://webtoon.daum.net/webtoon/view/#{nickname}

  doc["data"].each do |webtoon|
    Webtoon.create(
          title: webtoon["title"],
          desc: webtoon["introduction"],
          score: webtoon["averageScore"], # 소수점 반올림 추가
          img_url: webtoon["appThumbnailImage"]["url"],
          url: "http://webtoon.daum.net/webtoon/view/#{webtoon['nickname']}"
    )
  end
  @webtoons = Webtoon.all
  # 5. view에서 보여주기 위해 @webtoons 에 담는다

  erb :webtoon_list
end

get '/week/:day' do
  day = params[:day]
  url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/#{day}"
  response = HTTParty.get(url)
  doc = JSON.parse(response.body)
  doc["data"].each do |webtoon|
    Webtoon.create(
        title: webtoon["title"],
        desc: webtoon["introduction"],
        score: webtoon["averageScore"], # 소수점 반올림 추가
        img_url: webtoon["appThumbnailImage"]["url"],
        url: "http://webtoon.daum.net/webtoon/view/#{webtoon['nickname']}"
    )
  end
  @webtoons = Webtoon.all
  erb :day
end
