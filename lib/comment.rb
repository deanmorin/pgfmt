# frozen_string_literal: true

class Comment
  attr_reader :text, :start_index, :end_index

  def initialize(text, start_index, end_index)
    @text = text
    @start_index = start_index
    @end_index = end_index
  end
end


class CommentParser
  def self.parse(sql)
    # cs = []
    # sql.split('').each_with_index { |c, i| cs << "#{c}: #{i}" }
    # puts cs.join("\t")
    line_comment_indexes = []
    block_comment_indexes = []
    i = 0
    until i == sql.size
      if sql[i] == "'"
        i = find_end_quote(sql, i + 1, "'")
      elsif sql[i] == '"'
        i = find_end_quote(sql, i + 1, '"')
      elsif sql[i] == '-' && sql[i + 1] == '-'
        parsed = parse_line_comment(sql, i + 2)
        line_comment_indexes << [parsed[:start_index], parsed[:end_index]]
        i = parsed[:i]
      elsif sql[i] == '/' && sql[i + 1] == '*'
        parsed = parse_block_comment(sql, i + 2)
        block_comment_indexes << [parsed[:start_index], parsed[:end_index]]
        i = parsed[:i]
      else
        i += 1
      end
    end
    LineCommentMaker.new(sql, line_comment_indexes).make
      # BlockCommentMaker.new(sql, block_comment_indexes).make
  end

  def self.find_end_quote(sql, i, type)
    until (sql[i] == type && sql[i + 1] != type) || i == sql.size - 1
      i = if sql[i] == type && sql[i + 1] == type
            i + 2
          else
            i + 1
          end
    end
    i + 1
  end

  def self.parse_line_comment(sql, i)
    start_index = i
    i += 1 while sql[i] != "\n" && i < sql.size
    {
      start_index: start_index,
      end_index: i,
      i: i + 1,
    }
  end

  def self.parse_block_comment(sql, i)
    start_index = i
    i += 1 until (sql[i] == '*' && sql[i + 1] == '/') || i == sql.size - 1
    {
      start_index: start_index,
      end_index: i,
      i: i + 1,
    }
  end

  private_class_method :find_end_quote, :parse_line_comment, :parse_block_comment
end

class LineCommentMaker
  def initialize(sql, line_comment_indexes)
    @sql = sql
    @indexes = line_comment_indexes
  end

  def make
    min_ws = min_leading_whitespace

    @indexes.map do |is|
      raw_comment = @sql[is.first..is.last]
      ws_count = leading_whitespace_count(raw_comment)

      # TODO: explain sloppy indentation vs purposful
      text_start = if min_ws.zero? && ws_count == 1
                     is.first + 1
                   else
                     is.first + min_ws
                   end
      text_end = is.last - (raw_comment.length - raw_comment.rstrip.length)
      text = @sql[text_start..text_end]

      Comment.new(text, is.first, is.last)
    end
  end

  private

  def min_leading_whitespace
    @indexes.map { |is| @sql[is.first..is.last] }.map { |s| leading_whitespace_count(s) }.min
  end

  def leading_whitespace_count(s)
    s.length - s.lstrip.length
  end
end
