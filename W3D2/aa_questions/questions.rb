require_relative 'questions_db'
require_relative 'users'
require_relative 'question_follows'
require_relative 'question_likes'
require 'byebug'

class Question
  attr_accessor :title, :body, :user_id
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body  = options['body']
    @user_id = options['user_id']
  end

  def self.find_by_id(id)
    question = QuestionsDB.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

    return nil if question.empty?

    Question.new(question.first)
  end

  def self.find_by_user_id(user_id)
    user = User.find_by_id(user_id)
    raise "#{user_id} not found in DB" unless user

    questions = QuestionsDB.instance.execute(<<-SQL, user.id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    # debugger
    questions.map { |question| Question.new(question) }
  end

  def author
    User.find_by_id(user_id)
  end

  def replies
    Reply.find_by_question_id(id)
  end

  def followers
    QuestionFollow.followers_for_question_id(id)
  end

  def likers
    QuestionLike.likers_for_question_id(id)
  end

  def num_likes
    QuestionLike.num_likers_for_question_id(id)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end
end
