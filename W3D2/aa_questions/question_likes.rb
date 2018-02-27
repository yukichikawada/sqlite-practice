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
end
