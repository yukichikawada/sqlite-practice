require_relative 'questions_db'
require_relative 'users'
require_relative 'questions'

class QuestionFollow
  attr_accessor :user_id, :question_id
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def self.find_by_id(id)
    question = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL

    return nil if question.empty?

    QuestionFollow.new(question.first)
  end

  def self.followers_for_question_id(question_id)
    question = Question.find_by_id(question_id)
    raise "#{question_id} not found" unless question

    users = QuestionsDB.instance.execute(<<-SQL, question.id)
      SELECT
        *
      FROM
        question_follows
      JOIN
        users
      ON
        users.id = question_follows.user_id
      WHERE
        question_follows.question_id = ?
    SQL

    users.map { |user| User.find_by_id(user['id']) }
  end

  def self.followed_questions_for_user_id(user_id)
    user = Question.find_by_id(user_id)
    raise "#{user_id} not found" unless user

    questions = QuestionsDB.instance.execute(<<-SQL, user.id)
      SELECT
        *
      FROM
        question_follows
      JOIN
        questions
      ON
        questions.id = question_follows.question_id
      WHERE
        question_follows.user_id = ?
    SQL

    questions.map { |q| Question.find_by_id(q['id']) }
  end

  def self.most_followed_questions(n)
    questions = QuestionsDB.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
      JOIN
        question_follows
      ON
        question_follows.question_id = questions.id
      JOIN
        users
      ON
        users.id = questions.user_id
      GROUP BY
        questions.id
      ORDER BY
        COUNT(users.id) DESC
      LIMIT ?
    SQL

    questions.map { |q| Question.new(q) }
  end
end
