class ImportAuction < ActiveRecord::Base

  validates_presence_of :category, :children_category, :name, :sku, :img, :import_id
  validates :import_id, uniqueness: true

  def self.export
    export_book = Spreadsheet::Workbook.new
    # ImportAuction.all.in_groups_of(65000).each_with_index do |import_auctions, index|
    #   export_sheet = export_book.create_worksheet name: "商品编号"+(index.zero? ? '' : index.succ.to_s)
    #   export_row = export_sheet.row(0)
    #   ["商品分类", "名称", "商品编号", "图片地址"].each do |name|
    #     export_row.push(name)
    #   end

    #   import_auctions.compact.each_with_index do |import_auction, index|
    #     category, name, sku, img = import_auction.category, import_auction.name, import_auction.sku, import_auction.img
    #     export_row = export_sheet.row(index.succ)
    #     export_row.push(category)
    #     export_row.push(name)
    #     export_row.push(sku)
    #     export_row.push(img)
    #   end
    # end

    export_sheet = export_book.create_worksheet name: "商品编号"
    export_row = export_sheet.row(0)
    ["商品分类", "商品次级分类", "名称", "商品编号", "图片地址"].each do |name|
      export_row.push(name)
    end
    index = 1
    Auction.all.each do |auction|
      import_auctions = ImportAuction.where(category: auction.category, children_category: auction.children_category).limit(auction.quantity)
      import_auctions.each do |import_auction|
        category, children_category, name, sku, img = import_auction.category, import_auction.children_category, import_auction.name, import_auction.sku, import_auction.img
        export_row = export_sheet.row(index)
        export_row.push(category)
        export_row.push(children_category)
        export_row.push(name)
        export_row.push(sku)
        export_row.push(img)
        index += 1
      end
    end
    export_book.write "#{Dir.home}/京东商品编号.xls"
    puts  "导出京东商品编号"
  end

end
