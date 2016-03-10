namespace :export do

  desc "倒出商品编码数据"

  task :sku => :environment do
    ImportAuction.delete_all
    Crawler.start
    ImportAuction.export
  end
end
