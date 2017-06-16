require 'awesome_print'
describe 'Doubles' do

  it 'allows stubbing methods' do
    dbl = double('Chants')
    allow(dbl).to receive(:hey!)
    expect(dbl).to respond_to(:hey!)
  end

  it 'allows stubbing response with a block' do
    dbl = double('Chants')
    # When I say 'Hey!'n you say 'Ho!'
    allow(dbl).to receive(:hey!) { 'Ho!' }
    # 'Hey!', 'Ho!'
    expect(dbl.hey!).to eq('Ho!')
  end

  it 'allows stubbing response with a #and_return' do
    dbl = double('Chants')
    # When I say 'Hey!', you say 'Ho!'
    allow(dbl).to receive(:hey!).and_return('Ho!')
    # 'Hey!', 'Ho!'
    expect(dbl.hey!).to eq('Ho!')
  end

  it 'allows stubing multiple methods with hash syntax' do
    person = double('Person')
    # Note this uses #receive_messafe, not #receive
    allow(person).to receive_messages(:full_name => 'Marty Smith', :initials => 'MTS')
    expect(person.full_name).to eq('Marty Smith')
    expect(person.initials).to eq('MTS')
  end

  it 'allows stubbing with a hash argument to #double' do
    person = double('Person', :full_name => 'Marthy Smith', :initials => 'MTS')
    expect(person.full_name).to eq('Marthy Smith')
    expect(person.initials).to eq('MTS')
  end

  it 'allows stubbing multiple responses with #and_return' do
    die = double('Die')
    allow(die).to receive(:roll).and_return(1,5,2,6)
    expect(die.roll).to eq(1)
    expect(die.roll).to eq(5)
    expect(die.roll).to eq(2)
    expect(die.roll).to eq(6)
    expect(die.roll).to eq(6) # continues returning last value
  end


  #
  #
  # Partial Test Doubles
  context 'with partial test doubles' do

    it 'allows stubbing instance methods on Ruby Classes' do
      time = Time.new(2010, 1, 1, 12, 0, 0)
      allow(time).to receive(:year).and_return(1975)

      expect(time.to_s).to eq('2010-01-01 12:00:00 -0800')
      expect(time.year).to eq(1975)
    end

    it 'allows stubbing instance methods on custom classes' do
      class SuperHero
        attr_accessor :name
      end

      hero = SuperHero.new
      hero.name = 'Superman'
      expect(hero.name).to eq('Superman')

      allow(hero).to receive(:name).and_return('Clark Hent')
      expect(hero.name).to eq('Clark Hent')

    end

    it 'allows stubbing class methods on Ruby Classes' do
      fixed = Time.new(2010, 1, 1, 12, 0, 0)
      allow(Time).to receive(:now).and_return(fixed)

      expect(Time.now).to eq(fixed)
      expect(Time.now.to_s).to eq('2010-01-01 12:00:00 -0800')
      expect(Time.now.year).to eq(2010)

    end

    it 'allows stubbing database calls a mock object' do
      class Customer
        attr_accessor :name
        def self.find
          # database lookup, returns one object
        end
      end

      dbl = double('Mock Customer')
      allow(dbl).to receive(:name).and_return('Bob')

      allow(Customer).to receive(:find).and_return(dbl)

      customer = Customer.find
      expect(customer.name).to eq('Bob')
    end

    it 'allows stubbing database calls with many mock objects' do
      class Customer
        attr_accessor :name

        def self.all
          # database lookup, returns array of objects
        end
      end

      c1 = double('First Customer', :name => 'Bob')
      c2 = double('Second Customer', :name => 'Mary')

      allow(Customer).to receive(:all).and_return([c1, c2])

      customers = Customer.all
      expect(customers[1].name).to eq('Mary')

    end

  end

  #
  #
  # Message Expectations
  context 'with message expectations' do

    it 'expects a call and allows a response' do
      dbl = double('Chant')
      expect(dbl).to receive(:hey!).and_return('Ho!')

      dbl.hey!
    end

    it 'does not matter which order' do
      dbl = double('Multi-Step Process')

      expect(dbl).to receive(:step_1)
      expect(dbl).to receive(:step_2)

      dbl.step_2
      dbl.step_1

    end

    it 'works with #ordered when order matters' do
      dbl = double('Multi-step Process')

      expect(dbl).to receive(:step_1).ordered
      expect(dbl).to receive(:step_2).ordered

      dbl.step_1
      dbl.step_2
    end

  end

  #
  #
  # Argument Constraints
  context 'with argument constrains' do

    it 'expects arguments will match' do
      dbl = double('Customer List')
      expect(dbl).to receive(:sort).with('name')
      dbl.sort('name')
    end

    it 'passes when any arguments are allowed' do
      dbl = double('Customer List')
      # The default if you don't use #with
      expect(dbl).to receive(:sort).with(any_args)
      dbl.sort('name')
    end

    it 'works the same with multiple arguments' do
      dbl = double('Customer List')
      expect(dbl).to receive(:sort).with('name', 'asc', true)
      dbl.sort('name', 'asc', true)
    end

    it 'allows constraining only some arguments' do
      dbl = double('Customer List')
      expect(dbl).to receive(:sort).with('name', anything, anything)
      dbl.sort('name', 'asc', true)
    end

    it 'allows using other matchers' do
      dbl = double('Customer List')
      expect(dbl).to receive(:sort).with(
        a_string_starting_with('n'),
        an_object_eq_to('asc') | an_object_eq_to('desc'),
        boolean
      )
      dbl.sort('name', 'asc', true)
    end

  end

end