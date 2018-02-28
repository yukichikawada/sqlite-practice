require_relative 'questions_db'

class QuestionLike
  attr_accessor :user_id, :qustion_id
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
        question_likes
      WHERE
        id = ?
    SQL

    return nil if question.empty?

    QuestionLike.new(question.first)
  end

  def self.likers_for_question_id(question_id)
    question = Question.find_by_id(question_id)
    raise "#{question_id} not found" unless question

    users = QuestionsDB.instance.execute(<<-SQL, question.id)
      SELECT
        *
      FROM
        users
      JOIN
        question_likes
      ON
        question_likes.user_id = users.id
      WHERE
        question_likes.question_id = ?
    SQL

    users.map { |u| User.new(u) }
  end

  def self.num_likers_for_question_id(question_id)
    question = Question.find_by_id(question_id)
    raise "#{question_id} not found" unless question

    count = QuestionsDB.instance.execute(<<-SQL, question.id)
      SELECT
        COUNT(*)
      FROM
        users
      JOIN
        question_likes
      ON
        question_likes.user_id = users.id
      WHERE
        question_likes.question_id = ?
    SQL

    count.first.values.first
  end

  def self.liked_questions_for_user_id(user_id)
    user = User.find_by_id(user_id)
    raise "#{user_id} not found" unless user

    questions = QuestionsDB.instance.execute(<<-SQL, user.id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_likes
      ON
        question_likes.question_id = questions.id
      WHERE
        question_likes.user_id = ?
    SQL

    questions.map { |question| Question.new(question) }
  end

  def self.most_liked_questions(n)
    questions = QuestionsDB.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        questions
      JOIN
        question_likes
      ON
        question_likes.question_id = questions.id
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
