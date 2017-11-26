#encoding: utf-8

require 'nokogiri'
require 'open-uri'

# 2つの同一サイトのURLからメインコンテンツを推定する
#
# @param 同一サイトのURL1
# @param 同一サイトのURL2
#
# @return メインコンテンツのXPath
def extract_main(url1, url2)
  html =  Nokogiri::HTML(open(url1))
  nodes1 = parse html, "";

  html =  Nokogiri::HTML(open(url2))
  nodes2 = parse html, "";
  
  # body tag 以下を抽出
  nodes = tree_flatten(nodes1,3,[]).find_all{|xs| xs[2] =~ /body/} + tree_flatten(nodes2,3,[]).find_all{|xs| xs[2] =~ /body/}

  # 子要素数が異なるノードを抽出
  diff_nodes = nodes.group_by{|xs| xs[2]}
    .find_all{|xs|xs[1].size != 1}
    .find_all{|xs|xs[1][0][1] != xs[1][1][1]}
    .map{|xs| [xs[0], (xs[1][0][1] - xs[1][1][1]).abs]}

  # メインコンテンツ(差分が最大のノード)を抽出
  main_contents = diff_nodes.max_by{|xs| xs[1]}
  main_contents[0]
end

# NokogiriのHTMLを解析して要素数を持ったノードの配列に再帰的に変換する.
#
# @param 解析するノード
# @param 親XPath
#
# @return [タグ名, 子要素数, XPath, 子要素]からなる木構造データ.
def parse node, parent_path
    cnts = {}
    node.children
      .find_all{|x| x.class.name == "Nokogiri::XML::Element"}
      .map do |x|
          cnts[x.name] = (cnts[x.name] == nil) ? 1 : cnts[x.name] + 1
          path = parent_path + "/" + x.name + "[#{cnts[x.name]}]"
          [x.name, x.children.size, path, parse(x, path)]
      end
  end
  
# rootノードに含まれるメインとなる画像タグを抽出
#
# @param 元HTML
# @param 開始ポイントのXPath
#
# @return [タグ名, XPath, Element]のimgタグの集合.
def find_images html, root_xpath
  def f node, parent_path
    cnts = {}
    node.children
      .find_all{|x| x.class.name == "Nokogiri::XML::Element"}
      .map do |x|
        cnts[x.name] = (cnts[x.name] == nil) ? 1 : cnts[x.name] + 1
        path = parent_path + "/" + x.name + "[#{cnts[x.name]}]"
        [x.name, path, x, f(x, path)]
      end
  end

  tree_flatten(f(html.at_xpath(root_xpath), root_xpath),3,[]).find_all{|x| x[0] == 'img'}
end

# 木構造を配列に展開する
#
# @param 木構造データ
# @param 要素数
#
# @return 木構造を展開した配列
def tree_flatten(nodes, len, r)
  nodes.map{|n|
    r << n[0..(len - 1)]
    tree_flatten(n[-1], len, r)
  }
  r
end
