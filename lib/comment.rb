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
    cs = []
    sql.split('').each_with_index { |c, i| cs << "#{c}: #{i}" }
    puts cs.join("\t")
    line_comment_indexes = []
    block_comment_indexes = []
    i = 0
    until i == sql.size do
      if sql[i] == ?'
        i = find_end_quote(sql, i + 1, ?')
      elsif sql[i] == ?"
        i = find_end_quote(sql, i + 1, ?")
      elsif sql[i] == ?- and sql[i + 1] == ?-
        parsed = parse_line_comment(sql, i + 2)
        line_comment_indexes << [parsed[:start_index], parsed[:end_index]]
        i = parsed[:i]
      elsif sql[i] == ?/ and sql[i+1] == ?*
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

  private

  def self.find_end_quote(sql, i, type)
    until (sql[i] == type and sql[i + 1] != type) or i == sql.size - 1
      if sql[i] == type and sql[i + 1] == type
        i += 2
      else
        i += 1
      end
    end
    i + 1
  end

  def self.parse_line_comment(sql, i)
    start_index = i
    while sql[i] != ?\n and i < sql.size
      i += 1
    end
    {
      :start_index => start_index,
      :end_index => i,
      :i => i + 1,
    }
  end

  def self.parse_block_comment(sql, i)
    start_index = i
    until (sql[i] == ?* and sql[i + 1] == ?/) or i == sql.size - 1
      i += 1
    end
    {
      :start_index => start_index,
      :end_index => i,
      :i => i + 1,
    }
  end
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

      # TODO explain sloppy indentation vs purposful
      text_start = if min_ws == 0 and ws_count == 1
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
