# coding: utf-8
module Handicraft
  module Helper
    def yield_or_default(message, default_message = "")
      message.nil? ? default_message : message
    end

    def handicraft_form_for(name, *args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      options = options.merge(:builder => Handicraft::Form)

      if options[:html] && options[:html][:class].nil?
        options[:html].merge!( :class => "form right-label" )
      elsif options[:html].nil?
        options[:html] = { :class => "form right-label" }
      end

      args = (args << options)
      form_for(name, *args, &block)
    end

    def breadcrumb( *crumb )
      p = TagNode.new( :p, :class => "breadcrumb" )
      p << crumb.join(' &gt; ')
      return p.to_s
    end

    def render_breadcrumb(args = {})
      return "" if @breadcrumbs.size == 0
      out = "<ul class=\"breadcrumbs #{args[:class]}\">"
      @breadcrumbs.each do |c|
        out += ("<li class=\"#{@breadcrumbs.index(c) == 0 ? 'first': ''}\">" + c + "</li>")
      end
      out += "</ul>"
      return out
    end

    def render_page_title
      title = @page_title ? "#{SITE_NAME} | #{@page_title}" : SITE_NAME rescue "SITE_NAME"
      content_tag("title", title, nil, false)
    end

    def render_body_tag
      class_attribute = ["#{controller_name}-controller","#{action_name}-action"].join(" ")
      id_attribute = (@body_id)? " id=\"#{@body_id}-page\"" : ""

      raw(%Q|<!--[if lt IE 7 ]>
<body class="#{class_attribute} ie6"><![endif]-->
<!--[if gte IE 7 ]>
<body class="#{class_attribute} ie"><![endif]-->
<!--[if !IE]>-->
<body#{id_attribute} class="#{class_attribute}">
<!--<![endif]-->|)

    end

    def s(html)
      sanitize( html, :tags => %w(table thead tbody tr td th ol ul li div span font img sup sub br hr a pre p h1 h2 h3 h4 h5 h6), :attributes => %w(id class style src href size color) )
    end

    def render_table(rows, renderrers, table_options = {})
      table_options = {
        :has_header => true,
        :has_row_info => false,
        :id => nil,
        :class_name => "auto"
      }.merge(table_options)

      table_tag_options = table_options[:id] ? { :id => table_options[:id], :class => table_options[:class_name] } : { :class => table_options[:class_name] }

      table = TagNode.new('table', table_tag_options)
      if table_options[:has_header] == true
        table << thead = TagNode.new(:thead)
        thead << tr = TagNode.new(:tr, :class => 'odd')

        renderrers.each do |renderrer|
          tr << th = TagNode.new(:th)
          th << renderrer[0]
        end
      end

      table << tbody = TagNode.new('tbody')
      row_info = {}
      row_info[:total] = rows.length
      rows.each_with_index do |row,i|
        row_info[:current] = i
        tbody << tr = TagNode.new('tr', :class => cycle("","odd") )
        renderrers.each do |renderrer|
          tr << td = TagNode.new('td')

          if renderrer[1].class == Proc
            if table_options[:has_row_info] == true
              td << renderrer[1].call(row, row_info)
            else
              td << renderrer[1].call(row)
            end
          else
            td << renderrer[1]
          end
        end
      end

      return table.to_s
    end

    # .current will be added to current action, but if you want to add .current to another link, you can set @current = ['/other_link']
    # TODO: hot about render_list( *args )
    def render_list(list=[], options={})
      if list.is_a? Hash
        options = list
        list = []
      end

      yield(list) if block_given?

      ul = TagNode.new('ul', :id => options[:id], :class => options[:class] )

      list.each_with_index do |content, i|
        item_class = []
        item_class << "first" if i == 0
        item_class << "last" if i == (list.length - 1)

        item_content = content
        item_options = {}

        if content.is_a? Array
          item_content = content[0]
          item_options = content[1]
        end

        if item_options[:class]
          item_class << item_options[:class]
        end

        link = item_content.match(/href=(["'])(.*?)(\1)/)[2] rescue nil

        if ( link && current_page?(link) ) || ( @current && @current.include?(link) )
          item_class << "active"
        end

        item_class = (item_class.empty?)? nil : item_class.join(" ")
        ul << li = TagNode.new('li', :class => item_class )
        li << item_content
      end

      return ul.to_s
    end

    # Composite pattern
    class TagNode
      include ActionView::Helpers::TagHelper

      def initialize(name, options = {})
        @name = name.to_s
        @attributes = options
        @children = []
      end

      def addClass(x)
        if @attributes[:class].blank?
          @attributes[:class] = x.to_s
        else
          @attributes[:class] = @attributes[:class] + " #{x}"
        end
      end

      def to_s
        value = @children.each { |c| c.to_s }.join
        content_tag(@name, value.to_s, @attributes, false)
      end

      def <<(tag_node)
        @children << tag_node
      end
    end
  end

  module ControllerHelper
    def set_breadcrumbs
      @breadcrumbs = ["<a href='/'>首頁</a>"]
    end

    def drop_breadcrumb(title=nil, url=nil)
      title ||= @page_title
      url ||= url_for
      if title
        @breadcrumbs.push("<a href=\"#{url}\">#{title}</a>")
      end
    end

    def no_breadcrumbs
      @breadcrumbs = []
    end
  end
end
