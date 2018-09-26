# frozen_string_literal: true

require 'comment'

RSpec.describe CommentParser, '.parse' do
  context 'both styles of comments' do
    sql = %(
      SELECT '-- Dean''s constant',
             "A ""Column""",
             -- very important
             column_three
       FROM my.table a        --the table it's from
            JOIN your.table b --the table it's joined to
              ON a.foo = b.foo
    )
    # expected = [['very important', 82, 95],
    #             ["the table it's from", 155, 173],
    #             ["the table it's joined to", 207, 230]]
    expected = [['very important', 81, 96],
                ["the table it's from", 155, 174],
                ["the table it's joined to", 207, 231]]
    subject { CommentParser.parse(sql).map { |c| [c.text, c.start_index, c.end_index] } }
    it { is_expected.to eq expected }
  end

  ## No end newline

  ## comment options
  #
  ## no comments
end
