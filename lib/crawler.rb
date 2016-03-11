
class Crawler
  class << self

    def start
      url = "http://data.eastmoney.com/xg/xg/default.html"
      page_num = 1
      loop do
        url = "http://datainterface.eastmoney.com/EM_DataCenter/JS.aspx?type=NS&sty=NSST&st=12&sr=-1&js=var%20bqiUVbDT={pages:(pc),data:[(x)]}&stat=1&rt=48589302&ps=50&p=#{page_num}"
        begin
          content = get(url).to_s
          stocks = eval(content.match(/\[.*\]/).to_s).collect{|stock| stock.split(",")}
          stocks.each do |stock|
            stock_code = stock[4]
            stock_name = stock[3]
            purchase_code = stock[5]
            purchase_at = stock[11]
            issue_price = stock[10].present? ? stock[10] : stock[34]
            return nil if purchase_at.to_date <= Date.current
          end
          url = "http://data.eastmoney.com/xg/xg/detail/603861.html"
          page = get url
          page.search("#tr_zqh") #中奖手机号

          puts "***********************#{url}报异常*****************************"
        end
        page_num += 1
      end

    end


    def get(url, times = 0)
      times += 1
      begin
        Nokogiri::HTML(open(url).read)
      rescue
        get(url, times) if times < 6
      end
    end

  end
end