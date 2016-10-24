//
//  ViewController.swift
//  CuteBunny
//
//  Created by chiggang on 2016.09.16
//  Copyright © 2016년 chiggang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
	// 토끼 이미지
	@IBOutlet weak var imgCharacter: UIImageView!
	
	// 터치 좌표
	var touchPos = CGPoint(x: 0, y: 0)
	
	// 토끼 이동을 위한 터치 누적 갯수
	var cntTouchStack = 0
	
	// 토끼의 점프 유무 체크
	var chkJump = false
	
	// 토끼 표정 애니메이션 유무 체크
	var chkThreadFace = false
	
	// 토끼 표정 애니메이션을 위한 스레드 카운터
	var cntThreadFace = 0

	// 메인 스레드에 접근하기 위한 큐를 정의함
	let queue = OperationQueue()
	
	// 토끼 달리기 애니메이션 이미지 목록
	var arrCharacterRunAni = [UIImage]()
	
	// 토끼 눈깜빡임 애니메이션 이미지 목록
	var arrCharacterFaceEyesAni = [UIImage]()
	
	// 토끼 입씰룩 애니메이션 이미지 목록
	var arrCharacterFaceEatAni = [UIImage]()
	
	
	// 뷰의 소스를 불러온 후 처리함
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// 토끼 달리기 애니메이션 이미지 목록을 정의함
		for i in 1...2 {
			let img = UIImage(named: "BunnyRun\(i).png")
			self.arrCharacterRunAni.append(img!)
		}
		
		// 토끼 눈깜빡임 애니메이션 이미지 목록을 정의함
		for i in 1...5 {
			let img = UIImage(named: "BunnyCloseEyes\(i).png")
			self.arrCharacterFaceEyesAni.append(img!)
		}
		
		// 토끼 입씰룩 애니메이션 이미지 목록을 정의함
		for i in 1...3 {
			let img = UIImage(named: "BunnyEat\(i).png")
			self.arrCharacterFaceEatAni.append(img!)
		}
		
		// 화면을 클릭함
		let gestureTapView: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.actionGestureTapView(_:)))
		gestureTapView.delegate = self
		self.self.view.addGestureRecognizer(gestureTapView)
		
		// 화면을 드래그함
		let gesturePanView: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.actionGesturePanView(_:)))
		gesturePanView.delegate = self
		self.self.view.addGestureRecognizer(gesturePanView)
		
		// 토끼를 클릭함
		let gestureTapCharater: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.actionGestureTapCharater(_:)))
		self.imgCharacter.isUserInteractionEnabled = true
		self.imgCharacter.addGestureRecognizer(gestureTapCharater)
		
		// 토끼를 길게 클릭함
		let gestureLongPressCharater: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.actionGestureLongPressCharater(_:)))
		self.imgCharacter.isUserInteractionEnabled = true
		self.imgCharacter.addGestureRecognizer(gestureLongPressCharater)
	}

	// 뷰의 화면을 불러온 후 처리함
	override func viewDidAppear(_ animated: Bool) {
		// 토끼 애니메이션을 초기화함
		self.imgCharacter.animationImages = self.arrCharacterRunAni
		self.imgCharacter.stopAnimating()

		// 토끼 애니메이션을 초기화함
		self.queue.addOperation { () -> Void in
			OperationQueue.main.addOperation({
				self.imgCharacter.animationImages = self.arrCharacterRunAni
				self.imgCharacter.stopAnimating()
			})
		}

		// 토끼의 현재 좌표를 기억함
		self.touchPos = self.imgCharacter.center

		// 토끼의 표정 스레드를 시작함
		let threadFace = Thread(target: self, selector: #selector(ViewController.characterFaceThread), object: nil)
		threadFace.start()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// 화면을 클릭함
	func actionGestureTapView(_ sender: UITapGestureRecognizer){
		// 토끼가 점프 중일 때는 토끼를 이동하지 않음
		if self.chkJump == true {
			return
		}
		
		// 토끼 표정 애니메이션 중일 때는 토끼 표정 애니메이션을 중지함
		if self.chkThreadFace == true {
//			self.imgCharacter.center = self.touchPos
			
			
			// 메인 스레드 큐 안에서 처리함
			self.queue.addOperation { () -> Void in
				OperationQueue.main.addOperation({
					self.imgCharacter.center = self.touchPos

					// 토끼 애니메이션을 초기화함
					self.imgCharacter.animationImages = self.arrCharacterRunAni
					self.imgCharacter.stopAnimating()
//					self.imgCharacter.center = self.touchPos
				})
			}
			self.imgCharacter.stopAnimating()
			
//			self.imgCharacter.stopAnimating()
//			self.imgCharacter.center = self.touchPos

			// 토끼 표정 애니메이션을 종료함
//			self.imgCharacter.animationImages = self.arrCharacterRunAni
//			self.imgCharacter.stopAnimating()
//			self.imgCharacter.center = self.touchPos

			self.chkThreadFace = false
			
			// 토끼 표정 애니메이션을 위한 스레드 카운터를 초기화함
			self.cntThreadFace = 0
			
			// 토끼 이동을 위한 터치 누적 갯수를 초기화함
			self.cntTouchStack = 0
		}

		

		
		
		

		
		
		// 
		let currentTouchPos = self.touchPos
		
		// 화면을 클릭한 좌표를 기억함
		self.touchPos = sender.location(in: self.view)

		// 사용자가 클릭한 좌표를 기준으로 최종 이동할 목표의 좌표를 계산함
		setDestinationPosition()

		print("aaa \(self.cntTouchStack)")
		
		// 토끼 이동을 위한 터치 누적 갯수가 처음인지 체크함
		if self.cntTouchStack == 0 {
//			self.imgCharacter.stopAnimating()
//			self.imgCharacter.center = currentTouchPos
			
			// 토끼 달리기 애니메이션을 시작함
			self.imgCharacter.animationImages = self.arrCharacterRunAni
			self.imgCharacter.animationDuration = 0.3
			self.imgCharacter.animationRepeatCount = 0
			self.imgCharacter.startAnimating()
			
			self.imgCharacter.center = currentTouchPos
		}
		self.imgCharacter.center = currentTouchPos
		
		// 토끼 이동을 위한 터치 누적 갯수를 증가시킴
		self.cntTouchStack += 1

		print("A \(self.cntTouchStack)")

		// 토끼 이동 애니메이션을 시작함
		UIView.animate(
			withDuration: 1.0
			, delay: 0.0
			, options: [.curveEaseInOut]
			, animations: {
				self.imgCharacter.center = self.touchPos
			}
			, completion: {
				finished in
				print("B \(self.cntTouchStack) \(self.imgCharacter.center):\(self.touchPos)")
				// 터치한 위치와 토끼의 이동 후 위치가 일치하면 달리기 애니메이션을 종료함
				if self.imgCharacter.center == self.touchPos {
					// 토끼 이동을 위한 터치 누적 갯수를 감소시킴
					self.cntTouchStack -= 1

					print("C \(self.cntTouchStack)")

					// 토끼 이동을 위한 터치 누적 갯수가 모두 소멸되었는지 체크함
					if self.cntTouchStack <= 0 {
						// 토끼 이동 애니메이션을 멈춤
						self.imgCharacter.stopAnimating()
						
						// 토끼 이동을 위한 터치 누적 갯수를 초기화함
						self.cntTouchStack = 0
						
						print("D \(self.cntTouchStack)")
					}
				}
			}
		)
	}
	
	// 화면을 드래그함
	func actionGesturePanView(_ sender: UITapGestureRecognizer){
		// 토끼가 점프 중일 때는 토끼를 이동하지 않음
		if self.chkJump == true {
			return
		}
		
		// 토끼 표정 애니메이션 중일 때는 토끼 표정 애니메이션을 중지함
		if self.chkThreadFace == true {
			// 토끼 표정 애니메이션을 종료함
			self.chkThreadFace = true
			
			// 토끼 표정 애니메이션을 위한 스레드 카운터를 초기화함
			self.cntThreadFace = 0
			
			// 메인 스레드 큐 안에서 처리함
			queue.addOperation { () -> Void in
				OperationQueue.main.addOperation({
					// 토끼 애니메이션을 초기화함
					self.imgCharacter.animationImages = self.arrCharacterRunAni
					self.imgCharacter.stopAnimating()
					self.imgCharacter.center = self.touchPos
				})
			}
			
			self.imgCharacter.center = self.touchPos
		}

		let posTap = sender.location(in: self.view)
		
		// 화면을 클릭한 좌표를 기억함
		self.touchPos = posTap
		
		// 사용자가 클릭한 좌표를 기준으로 최종 이동할 목표의 좌표를 계산함
		setDestinationPosition()

		// 토끼 이동을 위한 터치 누적 갯수가 처음인지 체크함
		if self.cntTouchStack == 0 {
			// 토끼 달리기 애니메이션을 시작함
			self.imgCharacter.animationImages = self.arrCharacterRunAni
			self.imgCharacter.animationDuration = 0.3
			self.imgCharacter.animationRepeatCount = 0
			self.imgCharacter.startAnimating()
		}
		
		// 토끼 이동을 위한 터치 누적 갯수를 증가시킴
		self.cntTouchStack += 1
		
		// 토끼 이동 애니메이션을 시작함
		UIView.animate(
			withDuration: 1.0
			, delay: 0.0
			, options: [.curveEaseInOut]
			, animations: {
				self.imgCharacter.center = self.touchPos
			}
			, completion: {
				finished in
				// 터치한 위치와 토끼의 이동 후 위치가 일치하면 달리기 애니메이션을 종료함
				if self.imgCharacter.center == self.touchPos {
					// 토끼 이동을 위한 터치 누적 갯수를 감소시킴
					self.cntTouchStack -= 1

					// 토끼 이동을 위한 터치 누적 갯수가 모두 소멸되었는지를 체크함
					if self.cntTouchStack <= 0 {
						// 토끼 이동 애니메이션을 멈춤
						self.imgCharacter.stopAnimating()
						
						// 토끼 이동을 위한 터치 누적 갯수를 초기화함
						self.cntTouchStack = 0
					}
				}
		})
	}

	// 토끼를 클릭함
	func actionGestureTapCharater(_ sender: UITapGestureRecognizer){
		// 토끼가 이동하지 않고 토끼가 점프 중이지 않을 때만 점프를 할 수 있음
		if self.cntTouchStack == 0 && self.chkJump == false {
			// 토끼의 현재 좌표를 기억함
			let currentPos: CGPoint = self.imgCharacter.center

			// 토끼 올라가기 애니메이션을 시작함
			UIView.animate(
				withDuration: 0.3
				, delay: 0.0
				, options: [.curveEaseOut]
				, animations: {
					self.imgCharacter.center = CGPoint(x: currentPos.x, y: currentPos.y - 50)
					self.chkJump = true
				}
				, completion: {
					finished in
					// 토끼 내려가기 애니메이션을 시작함
					UIView.animate(
						withDuration: 0.3
						, delay: 0.01
						, options: [.curveEaseIn]
						, animations: {
							self.imgCharacter.center = currentPos
						}
						, completion: nil)
					
					self.chkJump = false
			})
		}
	}
	
	// 토끼를 길게 클릭함
	func actionGestureLongPressCharater(_ sender: UILongPressGestureRecognizer){
		switch sender.state {
		// 긴 터치를 시작함
		case UIGestureRecognizerState.began:
			// 토끼 확대 애니메이션을 시작함
			UIView.animate(
				withDuration: 0.3
				, delay: 0.0
				, options: [.curveEaseOut]
				, animations: {
					self.imgCharacter.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
				}
				, completion: {
					finished in
					// 토끼 축소 애니메이션을 시작함
					UIView.animate(
						withDuration: 0.3
						, delay: 0.01
						, options: [.curveEaseIn]
						, animations: {
							self.imgCharacter.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
						}
						, completion: nil)
			})
			
		// 긴 터치를 종료함
		case UIGestureRecognizerState.ended:
			print("토끼 길게 클릭 : End")
			
		// 긴 터치 중 드래그를 함
		case UIGestureRecognizerState.changed:
			print("토끼 길게 클릭 : Change")
			
		// 기본값
		default:
			print("토끼 길게 클릭 : ?")
		}
	}
	
	// 토끼의 표정 스레드를 처리함
	func characterFaceThread() {
		while Thread.current.isCancelled == false {
			// 토끼에 아무러 입력을 하지 않은 상태일 때만 처리함
			if self.cntTouchStack == 0 && self.chkJump == false && self.chkThreadFace == false {
				// 2초마다 한번씩 랜덤으로 표정을 변화함
				if self.cntThreadFace >= 2 {
					// 토끼 표정 애니메이션을 시작함
					self.chkThreadFace = true

					// 랜덤을 통해 표정을 변경함(1:눈깜빡임, 2~4:입씰룩)
					let rnd = Int(arc4random_uniform(3) + 1)
					
					if rnd == 1 {
						self.imgCharacter.animationImages = self.arrCharacterFaceEyesAni
						self.imgCharacter.animationDuration = 0.3
						self.imgCharacter.animationRepeatCount = 1
					} else if rnd >= 2 && rnd <= 4 {
						self.imgCharacter.animationImages = self.arrCharacterFaceEatAni
						self.imgCharacter.animationDuration = 0.2
						self.imgCharacter.animationRepeatCount = 10 // 3
					}
					
					// 토끼 표정 애니메이션의 총 재생시간
					let timeCharacterAnimationDuration = self.imgCharacter.animationDuration * Double(self.imgCharacter.animationRepeatCount)

					// 메인 스레드 큐 안에서 처리함
					self.queue.addOperation { () -> Void in
						OperationQueue.main.addOperation({
							UIView.animate(
								withDuration: 2.0
								, animations: {
									self.imgCharacter.startAnimating()
								}
								, completion: {
									finished in
									// 표정 애니메이션이 완료된 후, 일정 시간을 기다리고 나서 토끼 표정 애니메이션 종료 프로세스를 실행함
									self.perform(#selector(ViewController.characterFaceThreadAnimation), with: self, afterDelay: timeCharacterAnimationDuration)
								}
							)
						})
					}
					
					self.imgCharacter.center = self.touchPos
				}
				
				// 토끼 표정 애니메이션을 위한 스레드 카운터를 +1 증가함
				self.cntThreadFace += 1
			} else {
				// 토끼가 이동 중일 때는 토끼 표정 애니메이션을 위한 스레드 카운터를 초기화함
				self.cntThreadFace = 0
			}

			// 스레드의 딜레이 간격을 1초로 정의함
			Thread.sleep(forTimeInterval: 1.0)
		}
	}
	
	// 토끼 표정 애니메이션을 종료함
	func characterFaceThreadAnimation() {
		// 토끼 표정 애니메이션을 종료함
		self.chkThreadFace = false
		
		// 토끼 표정 애니메이션을 위한 스레드 카운터를 초기화함
		self.cntThreadFace = 0

		self.imgCharacter.center = self.touchPos

		// 메인 스레드 큐를 모두 제거함
		queue.cancelAllOperations()

		// 토끼 애니메이션을 초기화함
		self.imgCharacter.animationImages = self.arrCharacterRunAni

		// 메인 스레드 큐 안에서 처리함
		self.queue.addOperation { () -> Void in
			OperationQueue.main.addOperation({
				// 토끼 애니메이션을 초기화함
				self.imgCharacter.stopAnimating()
				self.imgCharacter.center = self.touchPos
			})
		}
	}
	
	// 사용자가 클릭한 좌표를 기준으로 최종 이동할 목표의 좌표를 보정하여 계산함
	func setDestinationPosition() {
		// 보정된 좌표를 사용할 것인지 체크함
		var chkX = false
		var chkY = false
		
		// 토끼의 크기를 기억함
		let characterSize = self.imgCharacter.frame.size
		
		// 사용자가 터치한 좌표를 기억함
		let destinationPos = self.touchPos
		
		/* 사용자가 클릭한 좌표를 기준으로 최종 이동할 목표의 좌표를 계산함 */
		
		var tmpPosX = destinationPos.x - (characterSize.width / 2)
		var tmpPosY = destinationPos.y - (characterSize.height / 2)
		
		if tmpPosX < 0 {
			tmpPosX = characterSize.width / 2
			chkX = true
		}
		
		if tmpPosY < 0 {
			tmpPosY = characterSize.height / 2
			chkY = true
		}
		
		if destinationPos.x + (characterSize.width / 2) > self.view.bounds.size.width {
			tmpPosX = self.view.bounds.size.width - (characterSize.width / 2)
			chkX = true
		}
		
		if destinationPos.y + (characterSize.height / 2) > self.view.bounds.size.height {
			tmpPosY = self.view.bounds.size.height - (characterSize.height / 2)
			chkY = true
		}
		
		if chkX == false {
			tmpPosX = destinationPos.x
		}
		
		if chkY == false {
			tmpPosY = destinationPos.y
		}
		
		// 최종 이동할 목표 좌표를 설정함
		self.touchPos = CGPoint(x: tmpPosX, y: tmpPosY)
	}
}

