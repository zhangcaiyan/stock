
class Crawler
  class << self

    def start
      # url = "http://dc.3.cn/category/get?callback=getCategoryCallback"
      # page = $agent.get url
      # data = JSON.parse page.body.gsub("getCategoryCallback(", '').gsub(/\)$/, '')
      Auction.all.each do |auction|
        crawler_auctions(auction)
      end

    end

    def crawler_auctions(auction)
      page_num = 1
      @@auction_num = ImportAuction.where(category: auction.category, children_category: auction.children_category).count

      loop do
        begin
          url = "http://list.jd.com/list.html?cat=#{auction.code}&sort=sort_commentcount_desc&delivery=1&page=#{page_num}"
          page = get url
          docs = page.search("#plist .gl-item")
          return nil if page_num > page.search("#J_topPage i").text.to_i
          puts "***********************#{auction.children_category}: 第#{page_num}页*****************************"
          docs.each do |doc|
            return nil if @@auction_num >= auction.quantity
            auction_url = doc.search(".p-name a").first.attributes["href"].value
            crawler_auction(auction_url, auction)
          end
        rescue
          puts "***********************#{url}报异常*****************************"
        end
        page_num += 1
      end
    end

    def crawler_auction(auction_url, auction)
      begin
        page = get auction_url
        img_text = page.search("#preview img").first.attributes["src"].value
        name = page.search("#preview img").first.attributes["alt"].value
        category = auction.category
        children_category = auction.children_category
        # sku = page.search("#short-share .fl span").last.text
        import_id = auction_url.match(/\d+(?=\.html)/).to_s
        sku = import_id # 商品编号就是商品ID
        img = img_text.start_with?("http") ? img_text : "http:#{img_text}"
        import_auction = ImportAuction.find_or_initialize_by(import_id: import_id)

        if import_auction.new_record?
          import_auction.category = category
          import_auction.children_category = children_category
          import_auction.name = name
          import_auction.sku = sku
          import_auction.img = img
          if import_auction.save!
            @@auction_num += 1
          end
        end
      rescue
        puts "***********************#{auction_url}报异常*****************************"
      end
    end

    def get(url, times = 0)
      times += 1
      begin
        $agent.get url
      rescue
        get(url, times) if times < 6
      end
    end

  end
end