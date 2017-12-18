DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/webtoon.db")

class Webtoon
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :desc, String
  property :score, Float
  property :img_url, String
  property :url, String
  property :created_at, DateTime
end

DataMapper.finalize

Webtoon.auto_upgrade!
