describe Curly::DelegatePresenter do
  class PersonPresenter < Curly::DelegatePresenter
    delegates :name, :age
  end

  it "allows exposing methods on the passed object" do
    context = double(:context)
    person = double(:person, name: "Jane", age: 25)
    presenter = PersonPresenter.new(context, person: person)

    expect(presenter.name).to eq "Jane"
    expect(presenter.age).to eq 25
  end
end
