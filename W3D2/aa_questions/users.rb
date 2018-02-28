require_relative 'questions_db'
require_relative 'questions'
require_relative 'question_follows'
require 'byebug'

class User
  attr_accessor :fname, :lname
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  # def save
  #   raise "#{self} already in database" if @id
  #   QuestionDB.instance.execute(<<-SQL, fname, lname)
  #     INSERT INTO
  #       plays (title, year, playwright_id)
  #     VALUES
  #       (?, ?, ?)
  #   SQL
  #   @id = PlayDBConnection.instance.last_insert_row_id
  # end

  def self.find_by_id(id)
    user = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    return nil if user.empty?

    User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDB.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL

    return nil if user.empty?

    user.map { |u| User.new(u) }
  end

  def authored_questions
    Question.find_by_user_id(id)
  end

  def authored_replies
    Reply.find_by_user_id(id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(id)
  end

  def average_karma
    num = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        -- question_likes.*, questions.*
        COUNT(DISTINCT(question_likes.id)), COUNT(DISTINCT(questions.id))
      FROM
        questions
      LEFT OUTER JOIN
        question_likes
      ON
        questions.id = question_likes.question_id
      WHERE
        questions.user_id = ?
    -- SELECT
    --   AVG(counts_table.count)
    -- FROM
    --     (SELECT
    --       COUNT(question_likes.id) AS count
    --     FROM
    --       question_likes
    --     JOIN
    --       users
    --     ON
    --       users.id = question_likes.user_id
    --     GROUP BY
    --       question_likes.question_id
    --     Having
    --       users.id = ?) as counts_table
    SQL

    # num.first.values.first
  end
end
