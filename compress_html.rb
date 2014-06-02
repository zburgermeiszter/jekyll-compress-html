# encoding: utf-8
require 'nokogiri'


module Jekyll
  module CompressHTMLFilter

    def compress_html(input)
      compress(input)
    end

  private

    BLOCK_ELEMENTS = 'div, h1, h2, h3, h4, h5, h6, li, meta, ol, p, ul'

    def compress(input)
      doc = Nokogiri::HTML::DocumentFragment.parse(input) { |config|
        # http://nokogiri.org/Nokogiri/XML/ParseOptions.html
        config.noerror.strict.noent
      }

      remove_comments(doc)
      remove_empty_block_elements(doc)

      doc.to_html(:save_with => Nokogiri::XML::Node::SaveOptions::AS_HTML).strip
    end

    def remove_empty_siblings(node)
      [node.previous_sibling, node.next_sibling, node].each { |n|
        n.remove if !n.nil? && n.content.strip.empty?
      }
    end

    def remove_comments(doc)
      doc.traverse { |node|
        node.remove if node.comment? && node.content !~ /\A(\[if|\<\!\[endif)/
      }
    end

    def remove_empty_block_elements(doc)
      doc.search(BLOCK_ELEMENTS).each { |node|
        remove_empty_siblings(node)
      }
    end

  end
end

Liquid::Template.register_filter(Jekyll::CompressHTMLFilter)
