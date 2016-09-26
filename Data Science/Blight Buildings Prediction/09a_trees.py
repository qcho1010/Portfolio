





# http://nbviewer.jupyter.org/github/savarin/pyconuk-introtutorial/blob/master/notebooks/Section%201-0%20-%20First%20Cut.ipynb
from sklearn.ensemble import RandomForestClassifier
model = RandomForestClassifier(n_estimators = 100)
model = model.fit(train_data[0:,1].reshape(-1,1), train_data[0:,0])
pred = model.predict(test_data[0:,1].reshape(-1,1))
print("rf: label ~ count   accuracy:")
metrics.accuracy_score(test.label,pred)
#0.57758968158000801

model = RandomForestClassifier(n_estimators = 100)
model = model.fit(train_data[0:,1:9], train_data[0:,0])
pred = model.predict(test_data[0:,1:9])
print("rf: label ~ count + keywords   accuracy:")
metrics.accuracy_score(test.label,pred)
#0.7574316290130797    => small decrease

model = RandomForestClassifier(n_estimators = 100)
model = model.fit(train_data[0:,[1,19,20]], train_data[0:,0])
pred = model.predict(test_data[0:,[0:,[1,19,20]])
print("rf: label ~ count + callcount + crimecount   accuracy:")
metrics.accuracy_score(test.label,pred)
#0.75822433610780815

model = RandomForestClassifier(n_estimators = 100)
model = model.fit(train_data[0:,[1,2,3,4,5,6,7,8,9,19,20]], train_data[0:,0])
pred = model.predict(test_data[0:,[1,2,3,4,5,6,7,8,9,19,20]])
print("rf: label ~ all counts + all keywords   accuracy:")
metrics.accuracy_score(test.label,pred)
#0.7546571541815299  => still worse than linear


from sklearn.grid_search import GridSearchCV

parameter_grid = {
    'max_features': [0.5, 1.],
    'max_depth': [5., None]
}

grid_search = GridSearchCV(RandomForestClassifier(n_estimators = 100), parameter_grid,cv=5, verbose=0)

gs=grid_search.fit(train_data[0:,1].reshape(-1,1), train_data[0:,0])
'{:.4f}'.format(gs.best_score_)
#'0.7602'
gs=grid_search.fit(train_data[0:,1:9], train_data[0:,0])
'{:.4f}'.format(gs.best_score_)
#'0.7618'
gs=grid_search.fit(train_data[0:,[1,19,20]], train_data[0:,0])
'{:.4f}'.format(gs.best_score_)
#'0.7606'
gs=grid_search.fit(train_data[0:,[1,2,3,4,5,6,7,8,9,19,20]], train_data[0:,0])
'{:.4f}'.format(gs.best_score_)
#'0.7624'



