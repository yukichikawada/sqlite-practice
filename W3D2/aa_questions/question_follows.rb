require_relative 'questions_db'
require_relative 'users'
require_relative 'questions'

class QuestionFollow
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
        question_follows
      WHERE
        id = ?
    SQL

    return nil if question.empty?

    QuestionFollowre.new(question.first)
  end

  def followers_for_question_id(question_id)
    question = Question.find_by_id(question_id)
    raise "#{question_id} not found" unless question

    users = QuestionsDB.instance.execute(<<-SQL, question.id)
      SELECT
        *
      FROM
        users
      WHERE
        question_id = ?
    SQL

    users.map { |user| User.new(user) }
  end
end
